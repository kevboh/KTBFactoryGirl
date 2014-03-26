//
//  KTBFactoryGirl.m
//  Little Spindle, LLC
//
//  Created by Kevin Barrett on 2/12/14.
//
//

#import "KTBFactoryGirl.h"
#import <CoreData/CoreData.h>

typedef id(^KTBFactoryGirlSequenceValueBlock)(NSInteger currentIndex);
@interface KTBFactoryGirlSequence ()
@property (readwrite, nonatomic, assign) NSInteger currentIndex;
@property (readwrite, nonatomic, assign) NSInteger startIndex;
@property (readwrite, nonatomic, assign) BOOL resetsAfterBuild;
@property (readwrite, nonatomic, copy) KTBFactoryGirlSequenceValueBlock valueBlock;
- (id)value;
- (void)increment;
- (void)reset;
@end

typedef NS_ENUM(NSInteger, KTBFactoryGirlBuildType) {
    KTBFactoryGirlBuildTypeObject,
    KTBFactoryGirlBuildTypeDictionary,
    KTBFactoryGirlBuildTypeCoreData
};
@interface KTBFactoryGirlBuilder : NSObject
@property (readwrite, nonatomic, assign) KTBFactoryGirlBuildType buildType;
@property (readwrite, nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (readwrite, nonatomic, strong) NSMutableSet *registeredSequences;
@property (readwrite, nonatomic, strong) NSMutableArray *objectStack;
+ (instancetype)objectBuilder;
+ (instancetype)dictionaryBuilder;
+ (instancetype)coreDataBuilderWithContext:(NSManagedObjectContext *)context;
- (id)buildRootObjectForFactory:(NSString *)factoryName setter:(void (^)(KTBFactoryGirl *itemFactory))itemDefinition;
- (id)build:(NSString *)factoryName setter:(void (^)(KTBFactoryGirl *itemFactory))itemDefinition;
- (id)currentParentObject;
- (Class)mutableCollectionClass;
- (void)cleanUp;
@end

typedef id(^KTBFactoryGirlValueDefinitionValueBlock)(KTBFactoryGirlBuilder *currentBuilder);
@interface KTBFactoryGirlValueDefinition : NSObject
@property (readwrite, nonatomic, copy) KTBFactoryGirlValueDefinitionValueBlock valueBlock;
@property (readwrite, nonatomic, strong) KTBFactoryGirlSequence *sequence;
@property (readwrite, nonatomic, assign) BOOL useParentForValue;
+ (instancetype)definitionWithValue:(id)value;
+ (instancetype)definitionWithBlock:(KTBFactoryGirlValueDefinitionValueBlock)valueBlock;
+ (instancetype)definitionWithSequence:(KTBFactoryGirlSequence *)sequence;
+ (instancetype)parentDefinition;
- (id)valueWithBuilder:(KTBFactoryGirlBuilder *)builder;
@end

@interface KTBFactoryGirl () <NSCopying>
@property (readwrite, nonatomic, copy) NSString *name;
@property (readwrite, nonatomic, copy) NSString *subjectClassName;
@property (readwrite, nonatomic, strong) NSMutableDictionary *valueDefinitionsKeyedByName;
@property (readwrite, nonatomic, strong) KTBFactoryGirl *superFactory;
@end

@implementation KTBFactoryGirl

+ (NSMutableDictionary *)factoryDefinitionsKeyedByName {
    static NSMutableDictionary *_factoryDefinitionsKeyedByName;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _factoryDefinitionsKeyedByName = [NSMutableDictionary dictionary];
    });
    return _factoryDefinitionsKeyedByName;
}

+ (void)define:(NSString *)factoryNameAndOrClass as:(void (^)(KTBFactoryGirl *factory))factoryDefinition {
    [self define:factoryNameAndOrClass class:NSClassFromString(factoryNameAndOrClass) as:factoryDefinition];
}

+ (void)define:(NSString *)factoryName class:(Class)subjectClass as:(void (^)(KTBFactoryGirl *factory))factoryDefinition {
    KTBFactoryGirl *factory = [KTBFactoryGirl new];
    factory.name = factoryName;
    factory.subjectClassName = NSStringFromClass(subjectClass);
    factory.entityName = factory.name;
    factoryDefinition(factory);
    [self factoryDefinitionsKeyedByName][factoryName] = factory;
}

+ (void)undefine:(NSString *)factoryName {
    [[self factoryDefinitionsKeyedByName] removeObjectForKey:factoryName];
}

+ (void)undefineAll {
    [[self factoryDefinitionsKeyedByName] removeAllObjects];
}

+ (id)build:(NSString *)factoryName {
    return [self build:factoryName setter:nil];
}

+ (id)build:(NSString *)factoryName setter:(void (^)(KTBFactoryGirl *itemFactory))itemDefinition {
    return [[KTBFactoryGirlBuilder objectBuilder] buildRootObjectForFactory:factoryName setter:itemDefinition];
}

+ (id)insert:(NSString *)factoryName intoContext:(NSManagedObjectContext *)managedObjectContext {
    return [[KTBFactoryGirlBuilder coreDataBuilderWithContext:managedObjectContext] buildRootObjectForFactory:factoryName setter:nil];
}

+ (id)insert:(NSString *)factoryName intoContext:(NSManagedObjectContext *)managedObjectContext setter:(void (^)(KTBFactoryGirl *itemFactory))itemDefinition {
    return [[KTBFactoryGirlBuilder coreDataBuilderWithContext:managedObjectContext] buildRootObjectForFactory:factoryName setter:itemDefinition];
}

+ (NSDictionary *)attributesFor:(NSString *)factoryName {
    return [[KTBFactoryGirlBuilder dictionaryBuilder] buildRootObjectForFactory:factoryName setter:nil];
}

+ (NSString *)JSONFor:(NSString *)factoryName options:(NSJSONWritingOptions)options error:(NSError *__autoreleasing *)error {
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[self attributesFor:factoryName]
                                                                          options:options
                                                                            error:error]
                                 encoding:NSUTF8StringEncoding];
}

- (id)init {
    self = [super init];
    if (self) {
        self.valueDefinitionsKeyedByName = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)set:(NSString *)key as:(id)value {
    self.valueDefinitionsKeyedByName[key] = [KTBFactoryGirlValueDefinition definitionWithValue:value];
}

- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    self.valueDefinitionsKeyedByName[key] = [KTBFactoryGirlValueDefinition definitionWithValue:obj];
}

- (void)set:(NSString *)key withBlock:(id (^)(void))valueBlock {
    if (valueBlock) {
        self.valueDefinitionsKeyedByName[key] = [KTBFactoryGirlValueDefinition definitionWithBlock:^id(KTBFactoryGirlBuilder *currentBuilder) {
            return valueBlock();
        }];
    }
}

- (void)set:(NSString *)key withFactory:(NSString *)factoryName {
    [self set:key withFactory:factoryName setter:nil];
}

- (void)set:(NSString *)key withFactory:(NSString *)factoryName setter:(void (^)(KTBFactoryGirl *itemFactory))itemDefinition {
    self.valueDefinitionsKeyedByName[key] = [KTBFactoryGirlValueDefinition definitionWithBlock:^id(KTBFactoryGirlBuilder *currentBuilder) {
        return [currentBuilder build:factoryName setter:itemDefinition];
    }];
}

- (void)set:(NSString *)key withFactory:(NSString *)factoryName count:(NSUInteger)count setter:(void (^)(KTBFactoryGirl *itemFactory, NSInteger itemIndex))itemDefinition {
    self.valueDefinitionsKeyedByName[key] = [KTBFactoryGirlValueDefinition definitionWithBlock:^id(KTBFactoryGirlBuilder *currentBuilder) {
        id valueCollection = [[[currentBuilder mutableCollectionClass] alloc] init];
        for (NSUInteger i = 0; i < count; i++) {
            id value = [currentBuilder build:factoryName setter:itemDefinition ? ^(KTBFactoryGirl *itemFactory) {
                itemDefinition(itemFactory, i);
            } : nil];
            
            if (value) {
                [valueCollection addObject:value];
            }
        }
        return valueCollection;
    }];
}

- (void)setKeyAsParent:(NSString *)key {
    self.valueDefinitionsKeyedByName[key] = [KTBFactoryGirlValueDefinition parentDefinition];
}

- (void)define:(NSString *)factoryName as:(void (^)(KTBFactoryGirl *factory))factoryDefinition {
    [self define:factoryName class:NSClassFromString(self.subjectClassName) as:factoryDefinition];
}

- (void)define:(NSString *)factoryName class:(Class)subjectClass as:(void (^)(KTBFactoryGirl *factory))factoryDefinition {
    __weak __typeof(self)weakSelf = self;
    [KTBFactoryGirl define:factoryName class:subjectClass as:^(KTBFactoryGirl *factory) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        factory.superFactory = strongSelf;
        
        factoryDefinition(factory);
    }];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    KTBFactoryGirl *copiedFactory = [KTBFactoryGirl new];
    copiedFactory.name = self.name;
    copiedFactory.subjectClassName = self.subjectClassName;
    copiedFactory.entityName = self.entityName;
    copiedFactory.valueDefinitionsKeyedByName = [self.valueDefinitionsKeyedByName mutableCopy];
    return copiedFactory;
}

@end

@implementation KTBFactoryGirlBuilder

+ (instancetype)objectBuilder {
    KTBFactoryGirlBuilder *builder = [KTBFactoryGirlBuilder new];
    builder.buildType = KTBFactoryGirlBuildTypeObject;
    return builder;
}

+ (instancetype)dictionaryBuilder {
    KTBFactoryGirlBuilder *builder = [KTBFactoryGirlBuilder new];
    builder.buildType = KTBFactoryGirlBuildTypeDictionary;
    return builder;
}

+ (instancetype)coreDataBuilderWithContext:(NSManagedObjectContext *)context {
    KTBFactoryGirlBuilder *builder = [KTBFactoryGirlBuilder new];
    builder.buildType = KTBFactoryGirlBuildTypeCoreData;
    builder.managedObjectContext = context;
    return builder;
}

- (id)init {
    self = [super init];
    if (self) {
        self.registeredSequences = [NSMutableSet set];
        self.objectStack = [NSMutableArray array];
    }
    return self;
}

- (id)buildRootObjectForFactory:(NSString *)factoryName setter:(void (^)(KTBFactoryGirl *itemFactory))itemDefinition {
    id obj = [self build:factoryName setter:itemDefinition];
    [self cleanUp];
    return obj;
}

- (id)build:(NSString *)factoryName setter:(void (^)(KTBFactoryGirl *itemFactory))itemDefinition {
    KTBFactoryGirl *factory = [KTBFactoryGirl factoryDefinitionsKeyedByName][factoryName];
    if (!factory || (self.buildType == KTBFactoryGirlBuildTypeObject && !factory.subjectClassName)) {
        return nil;
    }
    
    if (itemDefinition) {
        factory = [factory copy];
        itemDefinition(factory);
    }
    
    if (self.buildType == KTBFactoryGirlBuildTypeObject) {
        id obj = [[NSClassFromString(factory.subjectClassName) alloc] init];
        return [self buildOnObject:obj fromFactory:factory];
    }
    else if (self.buildType == KTBFactoryGirlBuildTypeDictionary) {
        id obj = [NSMutableDictionary dictionary];
        return [NSDictionary dictionaryWithDictionary:[self buildOnObject:obj fromFactory:factory]];
    }
    else if (self.buildType == KTBFactoryGirlBuildTypeCoreData) {
        id obj = [NSEntityDescription insertNewObjectForEntityForName:factory.entityName inManagedObjectContext:self.managedObjectContext];
        return [self buildOnObject:obj fromFactory:factory];
    }
    else {
        return nil;
    }
}

- (id)buildOnObject:(id)obj fromFactory:(KTBFactoryGirl *)factory {
    // Push object onto object stack
    [self.objectStack insertObject:obj atIndex:0];
    
    // Add attributes
    KTBFactoryGirl *currentFactory = factory;
    while (currentFactory != nil) {
        [self setAttributesOnBuildObject:obj fromFactory:currentFactory];
        currentFactory = currentFactory.superFactory;
    }
    
    // Pop object off object stack
    [self.objectStack removeObjectAtIndex:0];
    
    return obj;
}

- (void)setAttributesOnBuildObject:(id)obj fromFactory:(KTBFactoryGirl *)factory {
    [factory.valueDefinitionsKeyedByName enumerateKeysAndObjectsUsingBlock:^(NSString *key, KTBFactoryGirlValueDefinition *definition, BOOL *stop) {
        if (definition.sequence && definition.sequence.resetsAfterBuild) {
            [self.registeredSequences addObject:definition.sequence];
        }
        [obj setValue:[definition valueWithBuilder:self] forKey:key];
    }];
}

- (Class)mutableCollectionClass {
    return self.buildType == KTBFactoryGirlBuildTypeCoreData ? [NSMutableSet class] : [NSMutableArray class];
}

- (void)cleanUp {
    for (KTBFactoryGirlSequence *sequence in self.registeredSequences) {
        [sequence reset];
    }
    [self.registeredSequences removeAllObjects];
}

- (id)currentParentObject {
    if ([self.objectStack count] > 1) {
        return self.objectStack[1];
    }
    return nil;
}

@end

@implementation KTBFactoryGirlValueDefinition

+ (instancetype)definitionWithValue:(id)value {
    if ([value isKindOfClass:[KTBFactoryGirlSequence class]]) {
        return [self definitionWithSequence:value];
    }
    
    return [self definitionWithBlock:^id(KTBFactoryGirlBuilder *currentBuilder) {
        return value;
    }];
}

+ (instancetype)definitionWithBlock:(id (^)(KTBFactoryGirlBuilder *currentBuilder))valueBlock {
    KTBFactoryGirlValueDefinition *definition = [KTBFactoryGirlValueDefinition new];
    definition.valueBlock = valueBlock;
    return definition;
}

+ (instancetype)definitionWithSequence:(KTBFactoryGirlSequence *)sequence {
    KTBFactoryGirlValueDefinition *definition = [KTBFactoryGirlValueDefinition new];
    definition.sequence = sequence;
    return definition;
}

+ (instancetype)parentDefinition {
    KTBFactoryGirlValueDefinition *definition = [KTBFactoryGirlValueDefinition new];
    definition.useParentForValue = YES;
    return definition;
}

- (id)valueWithBuilder:(KTBFactoryGirlBuilder *)builder {
    if (self.valueBlock) {
        return self.valueBlock(builder);
    }
    else if (self.sequence) {
        NSNumber *sequenceValue = [self.sequence value];
        [self.sequence increment];
        return sequenceValue;
    }
    else if (self.useParentForValue) {
        return [builder currentParentObject];
    }
    return nil;
}

@end

@implementation KTBFactoryGirlSequence

+ (instancetype)sequence {
    return [self sequenceFrom:0];
}

+ (instancetype)sequenceFrom:(NSInteger)start {
    KTBFactoryGirlSequence *seqeunce = [KTBFactoryGirlSequence new];
    seqeunce.startIndex = seqeunce.currentIndex = start;
    return seqeunce;
}

- (id)value {
    if (self.valueBlock) {
        return self.valueBlock(self.currentIndex);
    }
    return @(self.currentIndex);
}

- (void)increment {
    self.currentIndex = self.currentIndex + 1;
}

- (id)thatResetsAfterBuild {
    self.resetsAfterBuild = YES;
    return self;
}

- (id)withBlock:(id (^)(NSInteger currentIndex))valueBlock {
    self.valueBlock = valueBlock;
    return self;
}

- (void)reset {
    self.currentIndex = self.startIndex;
}

@end