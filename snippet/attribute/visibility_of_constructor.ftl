<#--
  Returns public if object is not a enum, otherwise private
-->
<#--stop if $modelObject is null-->
<#if !(modelObject)??>  <#stop "modelObject not found in context" ></#if>
<#---->
<#assign isEnum = modelObject.getMetaData("enum")>
${metafactory.log("Object is enum? ${isEnum}")}
<#if isEnum == "true">
  private
<#else>
  public
</#if>
