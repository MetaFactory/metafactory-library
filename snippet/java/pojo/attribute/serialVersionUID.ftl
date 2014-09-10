<#--
  Sets the integer value of the field serialVersionUID by reading it from the current model object from the object
  property (metadata) serialVersionUID. If this property doesn't exist, it's added by MetaFactory to the model with
  value 1.
-->
<#--stop if $currentModelObject is null-->
<#if !(currentModelObject)??>  <#stop "currentModelObject not found in context" ></#if>
<#assign serialVersionUID = generator.getElementPropertyAsInt(currentModelObject, "serialVersionUID", 1)>
${serialVersionUID}