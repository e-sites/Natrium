# Natrium configuration

## .natrium.yml

### Example

```yaml
---
environments:
  - Staging
  - Production

natrium_variables:
   DeeplinkUrlSchemeName:
     Staging: "natriumexample_staging"    
     Production: "natriumexample"    

xcconfig:
    PRODUCT_BUNDLE_IDENTIFIER:
        Staging: com.esites.app.staging
        Production:
            Adhoc,Debug: com.esites.app.production
            Release: com.esites.app
    DEEPLINK_URL_SCHEME: "#{DeeplinkUrlSchemeName}"

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
    triggerError: "#error"
    deeplinkUrlSchemeName: "#{DeeplinkUrlSchemeName}"
    apiKey:
        Staging: "api_key_staging"
        Production: "#env(API_KEY_PRODUCTION)"

plists:
    "NatriumExampleProject/Info.plist":
        CFBundleDisplayName:
            Staging: App_staging
            Production: App
    "NatriumExampleProject/App.entitlements":
        "aps-environment":
            "*":
                Debug: "development"
                Release: "production"

files:
    Firebase/GoogleService-Info.plist:
        Dev: Firebase/GoogleService-Info_DEV.plist
        Staging: Firebase/GoogleService-Info_STAGING.plist
        Production: Firebase/GoogleService-Info_PRODUCTION.plist

target_specific:
    NatriumExampleProject2:
      variables:
          testVariableString: "Target #2"
      infoplist:
        CFBundleDisplayName: "App #2"
        
appicon:
    original: icon.png
    appiconset: NatriumExampleProject/Assets.xcassets/AppIcon.appiconset/
    idioms: 
        - ipad
        - iphone
    ribbon:
        Production: ""
        Staging: "STAGING"

launch_screen_versioning:
    path: NatriumExampleProject/Base.lproj/LaunchScreen.storyboard
    labelName: LaunchScreenVersionLabel
    enabled:
        Staging: true
        Production: false
```

Key               | Type                            | Description
----------------- | ------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
environments      | Array                           | Which environments does your project support
settings          | [Settings](#settings)           | Some settings
natrium_variables | Dictionary*                     | Use variables within the yml file. In this build config file `#{value_name}` will be replaced with the corresponding value. ⚠️ Only compatible with string types.
xcconfig          | Dictionary*                     | Build settings per environment / configuration
variables         | Dictionary*                     | Custom variables per environment / configuration (written in Natrium.swift). See [Special variables](#special-variables) for more advanced variable types.
plists         | Dictionary<sup><u>1</u></sup>*                     | Individual plist file locations with corresponding environment / configuration values.
files             | Dictionary<sup><u>2</u></sup>*                     | Overwrite a specific file per environment / configuration. Relative to path the project directory.
target_specific   | Dictionary<sup><u>3</u></sup>*                  | Target specific values. The first key of this dictionary is the target name, the value of that dictionary is the same as the values shown above (`infoplist`, `xcconfig`, `variables`, `files`, `appicon`). This way you can make target specific modifications per build.
appicon           | [App-icon](#app-icon)           | Place a ribbon on your app-icon
launch\_screen\_versioning              | [Launch screen versioning](#launch-screen-versioning) | Launch screen settings

- [See the Xcode Build Settings Reference](https://pewpewthespells.com/blog/buildsettings.html)
- [Checkout the platform specific Property list keys](https://developer.apple.com/library/mac/documentation/General/Reference/InfoPlistKeyReference/Articles/AboutInformationPropertyListFiles.html#//apple_ref/doc/uid/TP40009254-SW1)
- [Use the online YAML validator to validate your .natrium.yml](http://www.yamllint.com/)

**Dictionary<sup><u>1</u></sup>***:    
The `plists` dictionary's first key is the filepath, the value should be of a `Dictionary*` type.

**Dictionary<sup><u>2</u></sup>***:    
The `files` dictionary's first key is the filepath, the value should be of a `Dictionary*` type.

**Dictionary<sup><u>3</u></sup>***:    
The `target_specific ` dictionary's first key is the target name, the value should be of a `Dictionary*` type.   
⚠️ A target specific variable must be set in the `variables` field, so it can only overwrite existing variables.

`Dictionary*` = All the dictionaries support different types of notations:

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

  # or use an asterisk (*) to define all the environments: 
  
  key:
      "*":
          Debug: debugValue
          Release: releaseValue
  ```
  
## Settings

Available settings:

Key       | Type      | Description
--------- | --------- | ---------------------------------------------------------------
class_name | String | Set the name of the class. This is only applicable if you do not run Natrium from CocoaPods. Default: `NatriumConfig`

## App icon

The `app-icon` setting has 4 options:

- `original`: The relative path (according to your project) of the original icon file (preferably a size of 1024x1024). Which can be used to place the ribbon on top of it.
- `appiconset`: The relative path (according to your project) of the `AppIcon.appiconset` folder, to store the icons in
- `ribbon`: The text that should be placed in the ribbon. An empty string (`""`) would remove the ribbon
- `idioms`: What idioms should be used. Array (`ipad`, `iphone`, `watch`, `car` or `mac`)

This option fills your App icon asset catalog with perfectly resized icons for each device.    
Completely with a custom ribbon at the bottom of the icon. All you need is a hi-res app icon.

> For git convenience add `Project/Resources/Assets.xcassets/AppIcon.appiconset` to your `.gitignore` file. 

## Launch screen versioning

Alter a `UILabel` in the LaunchScreen storyboard to show the current app version.

Arguments:

Key       | Type      | Description
--------- | --------- | ---------------------------------------------------------------
path      | String *  | Relative path to the LaunchScreen.storyboard file
labelName | String *  | The accessability label value of the UILabel in that storyboard
enabled   | Boolean * | Disabling this will empty the UILabel

## Special variables

Key       | Description
--------- | ---------------------------------------------------------------
`#error`  | If you want Natrium to throw an error.
`#env(KEY)` | If you want to use a environment variable (from a CI system for instance), you can use this (e.g. `"#env(API_KEY_PRODUCTION)"`).