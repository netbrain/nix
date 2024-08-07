{ pkgs, config, ... }:
{
    home.file."m2-settings.xml" = {
      target = ".m2/settings.xml";
      text = ''
      <settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
        <servers>
          <server>
            <id>nexus.altibox.net</id>
            <username>kimei</username>
            <password>{/9x0H49imr4HfnarKGXib9LhG9LHWNBVgc5rCOsap1E=}</password>
          </server>
        </servers>
        <mirrors>
          <mirror>
              <id>nexus.altibox.net</id>
              <url>https://nexus.altibox.net/repository/mvn-group-all</url>
              <mirrorOf>*</mirrorOf>
          </mirror>
        </mirrors>
      </settings>  
      '';
    };
}
