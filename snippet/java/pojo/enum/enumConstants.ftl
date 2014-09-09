<#--stop if $currentModelObject is null-->
<#if !(currentModelObject)??>  <#stop "currentModelObject not found in context" ></#if>

<#assign modelobject = currentModelObject>
<#assign modelObjectName = modelobject.getAttributeValue("name")>
<#assign enumConstants = generator.getElementProperty(modelobject, "enum.constants", "LIST_CSV_OF_YOUR_ENUM_CONSTANTS-")> <#-- force a java compiler error -->
  ${enumConstants}
