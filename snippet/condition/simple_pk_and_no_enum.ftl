<#-- returns true if current model object has not a composite pk, but a simple primary key and is not a enum -->

<#--stop if $modelObject is null-->
<#if !(modelObject)??>  <#stop "modelObject not found in context" ></#if>

<#assign compositePk = modelObject.hasMetaData("database.pk.composite", "true") >
<#assign isEnum = modelObject.getMetaData("enum", "false") >
<#if (isEnum=="false" && !compositePk)>
  true
<#else>
  false
</#if>
