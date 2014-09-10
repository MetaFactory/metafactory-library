<#--
  Finds all attributes and references with the property businesskey and add these elements to the list named
  sortedBusinessKeyFields, which is sorted by the value of the businesskey property.
  The unsorted list (with the same order as the model) is named businessKeyFields
-->
<#--stop if $currentModelPackage is null-->
<#if !(currentModelPackage)??>  ${generator.error("currentModelPackage not found in context")} </#if>

<#--stop if $currentModelObject is null-->
<#if !(currentModelObject)??>  <#stop "currentModelObject not found in context" ></#if>

<#--stop if $comparatorFactory is null-->
<#if !(comparatorFactory)??>  <#stop "comparatorFactory not found in context" ></#if>

<#assign modelPackage = currentModelPackage >
<#assign modelObjectName = currentModelObject.getAttributeValue("name") >
<#assign modelObjectNameFL = generator.firstLower(modelObjectName) >

<#--Get all attributes with property businesskey -->
<#assign bkAttributes = generator.findChildrenByProperty(currentModelObject, "attribute", "businesskey")>

<#--Get all references with property businesskey -->
<#assign bkReferences = generator.findChildrenByProperty(currentModelObject, "reference", "businesskey")>
<#assign businessKeyFields = bkAttributes>
<#if businessKeyFields.addAll(bkReferences)> <#--trick to ignore result of addAll method--></#if>

<#--comparator sorts elements by value of the specified property-->
<#assign comparator = comparatorFactory.createElementComparator("businesskey" )>
<#assign sortedBusinessKeyFields = generator.sort(businessKeyFields, comparator)>
