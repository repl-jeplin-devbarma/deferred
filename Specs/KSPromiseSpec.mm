#import <Cedar/Cedar.h>
#import "KSPromise.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(KSPromiseSpec)

describe(@"KSPromise", ^{

    __block KSPromise<NSString *> *promise;

    describe(@"constructors", ^{
        describe(@"+resolve:", ^{
            it(@"should create a resolved promise with the argument", ^{
                KSPromise<NSString *> *promise = [KSPromise resolve:@"A"];

                promise.fulfilled should equal(YES);
                promise.value should equal(@"A");
            });
        });

        describe(@"+reject:", ^{
            it(@"should create a rejected promise with the argument", ^{
                NSError *error = [NSError errorWithDomain:@"ERROR" code:0 userInfo:nil];
                KSPromise<NSString *> *promise = [KSPromise reject:error];

                promise.rejected should equal(YES);
                promise.error should equal(error);
            });
        });
    });


    describe(@"then:", ^{
        describe(@"for fulfilled promises", ^{
            beforeEach(^{
                promise = [KSPromise promise:^(resolveType resolve, rejectType reject) {
                    resolve(@"A");
                }];
            });
            
            it(@"must return a new promise", ^{
                KSPromise<NSString *> *thenPromise = [promise then:nil];
                
                thenPromise should_not be_same_instance_as(promise);
            });
            
            it(@"calls the fulfillment callback", ^{
                __block BOOL done = NO;
                [promise then:^NSString*(NSString *value) {
                    value should equal(@"A");
                    done = YES;
                    return value;
                }];
                done should equal(YES);
            });
        });
        
        describe(@"for rejected promises", ^{
            __block NSError *error;
            beforeEach(^{
                error = [NSError errorWithDomain:@"Broken" code:1 userInfo:nil];
                
                promise = [KSPromise promise:^(resolveType resolve, rejectType reject) {
                    reject(error);
                }];
            });

            it(@"rejects the returned promise with the original error", ^{
                KSPromise *nextPromise = [promise then:nil];
                nextPromise.error should equal(error);
            });
        });
    });
});

SPEC_END
