{config, ...}: let
  inherit (config) serviceOpts;
  userMappingXml = builtins.toFile "guacamole-xml" ''
    <user-mapping>
        <authorize username="ryan" password="test">
          <connection name="local-client">
              <protocol>rdp</protocol>
              <param name="hostname">localhost</param>
              <param name="port">3389</param>
              <param name="ignore-cert">true</param>
          </connection>
        </authorize>
    </user-mapping>
  '';
in {
  # Define services
  services = {
    guacamole-server = {
      enable = true;
      host = "127.0.0.1";
      port = 4822;
      inherit userMappingXml;
    };
    guacamole-client = {
      enable = true;
      enableWebserver = true;
      settings = {
        guacd-port = 4822;
        guacd-hostname = "localhost";
      };
    };
    #    tomcat.serverXml = ''
    #      <?xml version="1.0" encoding="UTF-8"?>
    #      <Server port="8005" shutdown="SHUTDOWN">
    #        <Listener className="org.apache.catalina.startup.VersionLoggerListener" />
    #        <Listener className="org.apache.catalina.core.AprLifecycleListener" />
    #        <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" />
    #        <Listener className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener" />
    #        <Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" />
    #        <GlobalNamingResources>
    #          <Resource name="UserDatabase" auth="Container"
    #                    type="org.apache.catalina.UserDatabase"
    #                    description="User database that can be updated and saved"
    #                    factory="org.apache.catalina.users.MemoryUserDatabaseFactory"
    #                    pathname="conf/tomcat-users.xml" />
    #        </GlobalNamingResources>
    #        <Service name="Catalina">
    #          <Connector port="8085" protocol="HTTP/1.1"
    #                     connectionTimeout="20000"
    #                     redirectPort="8445"
    #                     maxParameterCount="1000"
    #                     />
    #          <Engine name="Catalina" defaultHost="localhost">
    #            <Realm className="org.apache.catalina.realm.LockOutRealm">
    #              <Realm className="org.apache.catalina.realm.UserDatabaseRealm"
    #                     resourceName="UserDatabase"/>
    #            </Realm>
    #
    #            <Host name="localhost"  appBase="webapps"
    #                  unpackWARs="true" autoDeploy="true">
    #              <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
    #                     prefix="localhost_access_log" suffix=".txt"
    #                     pattern="%h %l %u %t &quot;%r&quot; %s %b" />
    #
    #            </Host>
    #          </Engine>
    #        </Service>
    #      </Server>
    #    '';
  };
  #  networking.firewall.allowedTCPPorts = [8085 8445];

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."guacamole" = {
    container = "10.10.1.17";
    subdomain = "rdp";
    port = 8085;
    protocol = "http";
  };
}
