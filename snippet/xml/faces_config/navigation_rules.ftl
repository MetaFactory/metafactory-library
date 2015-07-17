<#--
  Dit is de template uit het project metafactory-library. Door dezelfde template in je MetaFactory project te zetten
  kan je deze template overschrijven door jouw project specifieke. Zo kan je dus zorgen voor een default template in
  je metafactory-library en kan je ook een project specifieke maken.
-->
  <navigation-rule>
    <from-view-id>/login.xhtml</from-view-id>
    <navigation-case>
      <from-action>${'#'}{identity.login}</from-action>
      <from-outcome>SUCCESS</from-outcome>
      <to-view-id>/index.xhtml</to-view-id>
      <redirect/>
    </navigation-case>
  </navigation-rule>
