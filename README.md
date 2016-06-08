![Natrium](Assets/logo.png)

A pre-build ruby script to alter your Xcode project at build time per environment and build configuration.
(swift only)

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Natrium.svg)](http://cocoadocs.org/docsets/Natrium)
[![Platform](https://img.shields.io/cocoapods/p/Natrium.svg?style=flat)](http://cocoadocs.org/docsets/Natrium)
[![Quality](https://apps.e-sites.nl/cocoapodsquality/Natrium/badge.svg?003)](https://cocoapods.org/pods/Natrium/quality)

## Installation

### CocoaPods

#### Step 1
Add the following to your `Podfile`:

```ruby
pod 'Natrium'
```
Run `pod install` or `pod update`

#### Step 2
Create `build-config.yml` in the root of your project (in the same folder as the .xcproject and .xcworkspace files).<br>
Check the configuration parameters [here](#configuration).

#### Step 3
Create a Pre-Action per scheme which runs the following script:

```shell
/bin/sh "${PROJECT_DIR}/Pods/Natrium/Natrium/script.sh" Staging
```
The final argument `"Staging"` is the actual environment you want to use for that specific scheme.<br>
This way you can create different schemes per environment

![Schemes](Assets/scheme.png)

#### Step 4 (Optional)

Add a `Run Script` Build Phase for your target(s):

```shell
/bin/sh "${PROJECT_DIR}/Pods/Natrium/Natrium/checkbuild.sh"
```

This step is optional, but can be useful to see if any errors occured during the run of the pre-action script. 
Since the pre-action script cannot throw build errors, this build phase run script is here to catch those potential errors and show them in your build log.

#### Step 5 (Optional)

Add it to your project

```swift
// AppDelegate.swift

import Natrium
let Config = Natrium.Config
```

This step is also optional, but this way you can use the `Config` class through your entire project without having to use the `import Natrium` statement in every class.

##Configuration

###build-config.yml

####Example

```yaml
environments:
  - Staging
  - Production

infoplist:
    CFBundleDisplayName:
        Staging: App_staging
        Production: App

    CFBundleIdentifier:
        Staging: com.esites.app.staging
        Production:
            Adhoc,Debug: com.esites.app.production
            Release: com.esites.app

xcconfig:
    ASSETCATALOG_COMPILER_APPICON_NAME:
        Staging: AppIcon1
        Production: AppIcon2

variables:
    testVariableDouble:
        Staging: 1.1
        Production: 5.5

    testVariableString:
        Staging,Production:
            Debug: "debugString"
            Adhoc: "adhocString"
            Release: "releaseString"
    testVariableBoolean: false
    testVariableInteger: 125
    
files:
    Firebase/GoogleService-Info.plist:
        Dev: Firebase/GoogleService-Info_DEV.plist
        Staging: Firebase/GoogleService-Info_STAGING.plist
        Production: Firebase/GoogleService-Info_PRODUCTION.plist
```

Key          | Type        | Description
------------ | ----------- | --------
environments | Array       | Which environments does your project support
infoplist    | Dictionary* | Keys of the Info.plist to be changed per environment / configuration
xcconfig     | Dictionary* | Build settings per environment / configuration
variables    | Dictionary* | Custom variables per environment / configuration (written in Config.swift) 
files		   | Dictionary* | Overwrite a specific file per environment / configuration. Relative to path the project directory.

* [See the Xcode Build Settings Reference](https://pewpewthespells.com/blog/buildsettings.html)
* [Checkout the platform specific Property list keys](https://developer.apple.com/library/mac/documentation/General/Reference/InfoPlistKeyReference/Articles/AboutInformationPropertyListFiles.html#//apple_ref/doc/uid/TP40009254-SW1)

\* All the dictionaries support different types of notations:

- **Every environment / configuration will use that `value`:**

  ```yaml
  key: value
  ```  
  
- **Differrent values per environment**

  ```yaml
  key: 
	    Staging: value1
	    Production: value2
  ```
  
- **Differrent values per environment and configuration**

  ```yaml
  key: 
	    Staging: 
	    	    Debug: stagingDebugValue
	    	    Release: stagingReleaseValue    
	    Production:
	    	    Debug: productionDebugValue
	    	    Release: productionReleaseValue
  ```
  
- **Differrent values per configuration**

  ```yaml
  key: 
	    Staging,Production: 
	    	    Debug: debugValue
	    	    Release: releaseValue    
  ```
  
  
## Usage
  
The example `build-config.yml` as shown above, will result in the following Config.swift file:
  
```swift
import Foundation

public class Config {
	public enum EnvironmentType {
	    case Staging
	    case Production
	}
	
	public static let environment:EnvironmentType = .Staging
	
	public static let testVariableDouble:Double = 1.1
	public static let testVariableString:String = "debugString"
	public static let testVariableBoolean:Bool = false
	public static let testVariableInteger:Int = 125
}
```

It can be used like so:

```swift
class ViewController: UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		print("bundle identifier: \(NSBundle.mainBundle().bundleIdentifier)")
		print("environment: \(Config.environment)")
	}
}
```

**Result:**

```
bundle identifier: Optional("com.esites.app.staging")
environment: Staging
```
