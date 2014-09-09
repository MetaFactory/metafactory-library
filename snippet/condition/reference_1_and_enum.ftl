<#--returns true if current reference is 0..1 or 1..1 and the reference is a enum-->
<#--stop if $currentModelPackage is null-->
<#if !(currentModelPackage)??>  <#stop "currentModelPackage not found in context"> </#if>

<#--stop if $currentModelObject is null-->
<#if !(currentModelObject)??>  <#stop "currentModelObject not found in context" ></#if>

<#--stop if $currentModelReference is null-->
<#if !(currentModelReference)??>  <#stop "currentModelReference not found in context" ></#if>

<#assign reference = currentModelReference>
<#assign referenceName = reference.getAttributeValue("name")>
<#assign referenceNameAU = referenceName?upper_case >
<#assign referenceType = reference.getAttributeValue("type")>
<#assign multiplicity = reference.getAttributeValue("multiplicity")>

<#if !(generator.findChildByAttribute(currentModelPackage, "object" , "name", referenceType))??>
  <#stop "object with name ${referenceType} not found in package ${currentModelPackage.getAttributeValue('name')}. Reference defined in object with name ${currentModelObject.getAttributeValue('name')}">
</#if>
<#assign referenceObjectElement = generator.findChildByAttribute(currentModelPackage, "object" , "name", referenceType)>
<#assign isEnum = generator.getElementProperty(referenceObjectElement, "enum")>

<#if (isEnum=="true" && (multiplicity == "0..1" || multiplicity == "1..1")) >
  true
<#elseif (isEnum=="true" && (multiplicity == "0..n" || multiplicity == "1..n")) >
  <#stop "enum references of type 0..n or 1..n not supported yet.">
<#else>
  false
</#if>