<#-- Insert a List and Add menuitem for all objects with property lazydatamodel -->

<#assign modelPackage = context.findModelPackage("domain_model") />
<#assign objects = modelPackage.getObjects() />
<#list objects as object>
  <#assign modelObjectName = object.name>
  <#assign modelObjectNameFL = modelObjectName?uncap_first />
	<!-- object = ${modelObjectName} -->

  <#assign lazydatamodelPropertyElements = object.findMetaDataByKey("lazydatamodel") />
  <#if (lazydatamodelPropertyElements?size gt 0) >
	  <#assign icon = object.getMetaData("primefaces.icon", "ui-icon ui-icon-note" ) />
	  <p:submenu label="${modelObjectName}" icon="${icon}" >
		  <#list lazydatamodelPropertyElements as lazydatamodelPropertyElement>
		    <#assign propertyValue = lazydatamodelPropertyElement.getText() />
		    <#assign listFacelet = "/list${propertyValue}.faces" />
		    <#assign editFacelet = object.getMetaData("list.${propertyValue}.editFacelet", "${modelObjectNameFL}Edit.xhtml" ) />
		      <p:menuitem value="All" url="${listFacelet}" />
		      <p:menuitem value="New" url="${editFacelet}" />
		  </#list>
	  </p:submenu>
	</#if>
</#list>

