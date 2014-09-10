<#--
  Returns public if object is not a enum, otherwise private
-->
<#--stop if $currentModelObject is null-->
<#if !(currentModelObject)??>  <#stop "currentModelObject not found in context" ></#if>
<#---->
<#assign isEnum = generator.getElementProperty(currentModelObject, "enum")>
${generator.log("Object is enum? ${isEnum}")}
<#if isEnum == "true">
  private
<#else>
  public
</#if>