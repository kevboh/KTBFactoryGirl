//
//  KTBFactoryGirl.h
//  Airendipity
//
//  Created by Kevin Barrett on 2/12/14.
//
//

#import <Foundation/Foundation.h>

@interface KTBFactoryGirl : NSObject
/**
 Name of entity used when inserting an object into a Core Data stack. Defaults to name of factory.
 */
@property (readwrite, nonatomic, copy) NSString *entityName;

// TODO: add coredata hooks to insert instead of build?

// Defining factories
/**
 Define a factory. If the name matches a known class, the factory will create objects of that class.
 Otherwise the factory can only be used to create dictionaries (see @c attributesFor:) and JSON (see @c JSONFor:options:error).
 */
+ (void)define:(NSString *)factoryNameAndOrClass as:(void (^)(KTBFactoryGirl *factory))factoryDefinition;
+ (void)define:(NSString *)factoryName class:(Class)subjectClass as:(void (^)(KTBFactoryGirl *factory))factoryDefinition;
+ (void)undefine:(NSString *)factoryName;
+ (void)undefineAll;

// Building factory objects
+ (id)build:(NSString *)factoryName;
+ (id)build:(NSString *)factoryName setter:(void (^)(KTBFactoryGirl *itemFactory))itemDefinition;
+ (id)insert:(NSString *)factoryName intoContext:(NSManagedObjectContext *)managedObjectContext;
+ (id)insert:(NSString *)factoryName intoContext:(NSManagedObjectContext *)managedObjectContext setter:(void (^)(KTBFactoryGirl *itemFactory))itemDefinition;
+ (NSDictionary *)attributesFor:(NSString *)factoryName;
+ (NSString *)JSONFor:(NSString *)factoryName options:(NSJSONWritingOptions)options error:(NSError **)error;

// Configuring factory definitions
- (void)set:(NSString *)key as:(id)value;
- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key;
- (void)set:(NSString *)key withBlock:(id (^)(void))valueBlock;
/**
 Sets a relation with a single object
 */
- (void)set:(NSString *)key withFactory:(NSString *)factoryName;
/**
 Sets a custom relation with a single object
 */
- (void)set:(NSString *)key withFactory:(NSString *)factoryName setter:(void (^)(KTBFactoryGirl *itemFactory))itemDefinition;
/**
 Sets a collection
 */
- (void)set:(NSString *)key withFactory:(NSString *)factoryName count:(NSUInteger)count setter:(void (^)(KTBFactoryGirl *itemFactory, NSInteger itemIndex))itemDefinition;
- (void)setKeyAsParent:(NSString *)key;

// Defining inherited factories
/**
 Defines a factory that inherits from the receiver. The class of the child factory is assumed to be that of the parent.
 Use @c define:class:as: to specify a particular class.
 */
- (void)define:(NSString *)factoryName as:(void (^)(KTBFactoryGirl *factory))factoryDefinition;
- (void)define:(NSString *)factoryName class:(Class)subjectClass as:(void (^)(KTBFactoryGirl *factory))factoryDefinition;

@end

@interface KTBFactoryGirlSequence : NSObject
+ (instancetype)sequence;
+ (instancetype)sequenceFrom:(NSInteger)start;
/**
 Calling this on a sequence will mark it to reset to its initial index after an object or object tree is built.
 */
- (id)thatResetsAfterBuild;
- (id)withBlock:(id (^)(NSInteger currentIndex))valueBlock;
@end
