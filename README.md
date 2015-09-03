
# WJHShouldTerminate.framework

[![Github release](https://img.shields.io/github/release/jodyhagins/WJHShouldTerminate.svg)](https://github.com/jodyhagins/WJHShouldTerminate/releases) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/jodyhagins/WJHShouldTerminate/master/LICENSE.md)

This is a simple framework with a single purpose: make handling voluntary application shutdown easier.

See [this blogpost](http://cocoaandgrits.blogspot.com/) from some background and a bit more explanation.

## Installation
[Carthage](https://github.com/carthage/carthage) is the recommended way to install WJHShouldTerminate.  Add the following to your Cartfile:

``` ruby
github “jodyhagins/WJHShouldTerminate”
```

For manual installation, I recommend adding the project as a subproject to your project or workspace and adding the framework as a target dependency.
 
## Usage 

In your AppDelegate, forward the responsibility of responding to `applicationShouldTerminate` to the library.

    - (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
        return [WJHShouldTerminate requestTerminationForApplication:sender];
    }

Wherever you want to intercept shutdown requests, register and handle the requests.

    [object wjh_setShouldTerminateBlock:^(WJHShouldTerminate *st) {
        id token = [st pauseTermination];
        [self saveDatabase:^(NSError *error) {
            // Handler error
            [token resume];
        }];
    }];

See the documentation for complete explanations of the entire API.
 
