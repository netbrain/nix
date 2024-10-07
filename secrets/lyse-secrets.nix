{ config, ... }:

{
  sops.secrets = {
    "maven/masterpass" = { };
    "lyse/maven/username" = { };
    "lyse/maven/password" = { };
  };

  sops.templates."maven-settings-security.xml" = {
    owner = "netbrain";
    content = ''
      <settingsSecurity>
        <master>${config.sops.placeholder."maven/masterpass"}</master>
      </settingsSecurity>
      '';
    path = "/home/netbrain/.m2/settings-security.xml";
  };
  
  sops.templates."lyse-maven-settings.xml" = {
    owner = "netbrain";
    content = ''
      <settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
        <servers>
          <server>
            <id>nexus.altibox.net</id>
            <username>${config.sops.placeholder."lyse/maven/username"}</username>
            <password>${config.sops.placeholder."lyse/maven/password"}</password>
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
      path = "/home/netbrain/.m2/settings.xml";
    };
  }
