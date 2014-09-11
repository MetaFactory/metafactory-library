<#-- returns true if current model object has a composite pk (instead of a simple primary key) and is not a enum -->

<#--stop if $currentModelObject is null-->
<#if !(currentModelObject)??>  <#stop "currentModelObject not found in context" ></#if>

<#assign compositePk = generator.elementContainsProperty(currentModelObject,"database.pk.composite", "true") >
<#assign isEnum = generator.getElementProperty( currentModelObject,"enum", "false") >
<#if (isEnum=="false" && compositePk)>
  true
<#else>
  false
</#if>