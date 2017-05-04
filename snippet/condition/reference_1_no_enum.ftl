<#-- returns true if current reference is 0..1 or 1..1 and the reference is not a enum -->
<#--stop if $modelPackage is null-->
<#if !(modelPackage)??>  <#stop "modelPackage not found in context"> </#if>

<#--stop if $modelObject is null-->
<#if !(modelObject)??>  <#stop "modelObject not found in context" ></#if>

<#--stop if $modelReference is null-->
<#if !(modelReference)??>  <#stop "modelReference not found in context" ></#if>

<#assign reference = modelReference>
<#assign referenceName = reference.name>
<#assign referenceNameAU = referenceName?upper_case >
<#assign referenceType = reference.type>
<#assign multiplicity = reference.multiplicity>

<#if !(modelPackage.findObjectByName(referenceType))??>
  <#stop "object with name ${referenceType} not found in package ${modelPackage.name}. Reference defined in object with name ${modelObject.name}">
</#if>
<#assign referenceObjectElement = modelPackage.findObjectByName(referenceType)>
<#assign isEnum = referenceObjectElement.getMetaData("enum")>

<#if (isEnum=="false" && (multiplicity == "0..1" || multiplicity == "1..1")) >
  true
<#else>
  false
</#if>
