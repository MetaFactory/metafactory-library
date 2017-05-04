<#--
  Sets the integer value of the field serialVersionUID by reading it from the current model object from the object
  property (metadata) serialVersionUID. If this property doesn't exist, it's added by MetaFactory to the model with
  value 1.
-->
<#--stop if $modelObject is null-->
<#if !(modelObject)??>  <#stop "modelObject not found in context" ></#if>
<#assign serialVersionUID = modelObject.getMetaData("serialVersionUID", "1")?number>
${serialVersionUID}
