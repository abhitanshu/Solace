# KarateGitlabIssueTesting


**Install Java 11**
```
1. Install Homebrew if you haven’t already: 
     $ /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)\"
2. Install OpenJDK 11: 
    $ brew install openjdk@11
3. Verify the installation: 
    $ java -version
```
**Install Maven**
```
1. Install Maven: 
    $ brew install maven
2. Verify the installation: 
    $ mvn -version

Maven official Documentation - https://maven.apache.org/guides/index.html 
```
**To Run from command line (dockerised local environment)**

```
 mvn clean test -Dkarate.importKey=476b272a-3d73-4272-b936-bd219c833e29 -Dkarate.eventsKey=684ee959-5126-421a-90ef-91b904774b41 -Dkarate.options="--tags @SDA"
This command will run all the tests with the tag @SDA
```

