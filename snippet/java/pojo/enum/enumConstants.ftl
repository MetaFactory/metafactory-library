<#--stop if $modelObject is null-->
<#if !(modelObject)??>  <#stop "modelObject not found in context" ></#if>

<#assign modelobject = modelObject>
<#assign modelObjectName = modelobject.name>
<#assign enumConstants = modelobject.getMetaData("enum.constants", "LIST_CSV_OF_YOUR_ENUM_CONSTANTS-")> <#-- force a java compiler error -->
  ${enumConstants}
