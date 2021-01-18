
# Installation using XcodeGen

After either installing it using Carthage, CocoaPods or manually you have to setup your XcodeGen's `project.yml` file

Here's an example I've been using with my projects using both Natrium and XcodeGen in combination with CocoaPods:

```yaml
schemeTemplates:
  TestScheme:
    build:
      targets:
        MyAppUITests: 
          - test
        MyAppTests:
          - test
    test:
      targets:
        - MyAppUITests
        - MyAppTests
        
  NatriumScheme:
    build:
      targets:
        MyApp: all
      preActions:
        - script: "\"${PROJECT_DIR}/Pods/Natrium/Natrium/natrium\" ${environment}"
          settingsTarget: MyApp
    archive:
      config: ${archiveConfig}

schemes:
  "MyApp (appstore-release)": 
    templates:
      - NatriumScheme
      - TestScheme
    templateAttributes:
      environment: Production
      archiveConfig: Release    
      
  "MyApp (production)":
    templates:
      - NatriumScheme
      - TestScheme
    templateAttributes:
      environment: Production
      archiveConfig: Adhoc
      
  "MyApp (staging)":
    templates:
      - NatriumScheme
      - TestScheme
    templateAttributes:
      environment: Staging
      archiveConfig: Adhoc

```