<rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="<%= $message_id %>">
  <edit-config>
    <target>
      <running/>
    </target>
 	  <config>
      <native xmlns="http://cisco.com/ns/yang/Cisco-IOS-XE-native">
        <interface>
          <GigabitEthernet>
            <name><%= $data->{"interface"} %></name>
            <encapsulation>
              <dot1Q>
                <vlan-id><%= $data->{"encapsulation"} %></vlan-id>
              </dot1Q>
            </encapsulation>
          </GigabitEthernet>
        </interface>
      </native>
    </config>
  </edit-config>
</rpc>
