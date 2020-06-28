<rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="<%= $message_id %>">
  <edit-config>
    <target>
      <running/>
    </target>
 	<config>
      <interfaces xmlns="urn:ietf:params:xml:ns:yang:ietf-interfaces">
        <interface>
            <name>GigabitEthernet2.500</name>
            <type xmlns:ianaift="urn:ietf:params:xml:ns:yang:iana-if-type">ianaift:ethernetCsmacd</type>
            <enabled>true</enabled>
        </interface>
      </interfaces>
     </config>
  </edit-config>
</rpc>
