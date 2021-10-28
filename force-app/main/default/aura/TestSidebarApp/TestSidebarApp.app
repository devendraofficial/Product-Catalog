<aura:application extends="force:slds" implements="lightning:isUrlAddressable">
    <aura:handler name="init" value="{!this}" action="{!c.doInit}" description="Handler for valueInit event fired when the component has been initialised"/>
        {!v.pageReference.state.id}
    <!--<c:TestSidebar/>-->
    <c:MainCatalog/>
</aura:application>