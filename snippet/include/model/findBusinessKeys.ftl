<#--
  Finds all attributes and references with the property businesskey and add these elements to the list named
  sortedBusinessKeyFields, which is sorted by the value of the businesskey property.
  The unsorted list (with the same order as the model) is named businessKeyFields
-->
<#--stop if $modelPackage is null-->
<#if !(modelPackage)??>  ${metafactory.error("modelPackage not found in context")} </#if>

<#--stop if $modelObject is null-->
<#if !(modelObject)??>  <#stop "modelObject not found in context" ></#if>

<#--stop if $comparatorFactory is null-->
<#if !(comparatorFactory)??>  <#stop "comparatorFactory not found in context" ></#if>


<#assign modelObjectName = modelObject.name >
<#assign modelObjectNameFL = metafactory.firstLower(modelObjectName) >

<#--Get all attributes with property businesskey -->
<#assign bkAttributes = modelObject.findAttributesByMetaData("businesskey")>

<#--Get all references with property businesskey -->
<#assign bkReferences = modelObject.findReferencesByMetaData("businesskey")>
<#assign businessKeyFields = bkAttributes>
<#if businessKeyFields.addAll(bkReferences)> <#--trick to ignore result of addAll method--></#if>

<#--comparator sorts elements by value of the specified property-->
<#assign comparator = comparatorFactory.createMetaDataComparator("businesskey" )>
<#assign sortedBusinessKeyFields = metafactory.sort(businessKeyFields, comparator)>
