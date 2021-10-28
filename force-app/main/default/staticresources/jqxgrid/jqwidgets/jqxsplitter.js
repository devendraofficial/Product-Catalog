/*
jQWidgets v4.5.1 (2017-April)
Copyright (c) 2011-2017 jQWidgets.
License: http://jqwidgets.com/license/
*/
!function(a){a.jqx.jqxWidget("jqxSplitter","",{}),a.extend(a.jqx._jqxSplitter.prototype,{defineInstance:function(){var b={width:300,height:300,panels:[],orientation:"vertical",disabled:!1,splitBarSize:5,touchSplitBarSize:15,panel1:null,panel2:null,_eventsMap:{mousedown:a.jqx.mobile.getTouchEventName("touchstart"),mouseup:a.jqx.mobile.getTouchEventName("touchend"),mousemove:a.jqx.mobile.getTouchEventName("touchmove"),mouseenter:"mouseenter",mouseleave:"mouseleave"},_isTouchDevice:!1,_isNested:!1,resizable:!0,touchMode:"auto",showSplitBar:!0,initContent:null,_events:["resize","expanded","collapsed","resizeStart","layout"]};return this===a.jqx._jqxSplitter.prototype?b:(a.extend(!0,this,b),b)},createInstance:function(){this.render()},_initOverlay:function(b){if(this.overlay||"undefined"==b)this.overlay.remove(),this.overlay=null;else if(1==b){this.overlay=a("<div style='z-index: 100; background: #fff;'></div>"),this.overlay.css("opacity",.01),this.overlay.css("position","absolute"),this.overlay.appendTo(a(document.body));this.host.coord();this.overlay.css("left","0px"),this.overlay.css("top","0px"),this.overlay.width(a(window).width()),this.overlay.height(a(window).height()),this.overlay.addClass("jqx-disableselect"),"horizontal"==this.orientation?this.overlay.css("cursor","row-resize"):this.overlay.css("cursor","col-resize")}},_startDrag:function(b){return!(b.target!=this.splitBarButton[0]&&!this.disabled)||(!(!this.panels[0].collapsed&&!this.panels[1].collapsed&&this.resizable)||(null!=this.overlay||(this._dragging=!0,this._initOverlay(!0),this._dragStart=a.jqx.position(b),!1)))},_drag:function(b){if(this.panels[0].collapsed||this.panels[1].collapsed||this.disabled)return!0;if(!this._dragging)return!0;var c="horizontal"==this.orientation?"top":"left",d="vertical"==this.orientation?"width":"height";if(this._position=a.jqx.position(b),this.overlay&&!this._splitBarClone&&Math.abs(this._position[c]-this._dragStart[c])>=3){var e=this.splitBar.coord();return this._cloneStart={left:e.left,top:e.top},this._splitBarClone=this._createSplitBarClone(),void this._raiseEvent(3,{panels:this.panels})}if(this._splitBarClone){var f,g,h=this.host[d](),i=h/100,j=0,k=this._splitBarClone[d]()+2,l=parseInt(this.host.coord()[c]),m=this._position[c]-this._dragStart[c]+this._cloneStart[c]-l;return j>m&&(m=j),m>h+j-k&&(m=h+j-k),f=this.panels[0].min,g=this.panels[1].min,g.toString().indexOf("%")!=-1&&(g=parseFloat(g)*i),f.toString().indexOf("%")!=-1&&(f=parseFloat(f)*i),this._splitBarClone.removeClass(this.toThemeProperty("jqx-splitter-splitbar-invalid")),m<f&&(this._splitBarClone.addClass(this.toThemeProperty("jqx-splitter-splitbar-invalid")),m=f),m>h+j-k-g&&(this._splitBarClone.addClass(this.toThemeProperty("jqx-splitter-splitbar-invalid")),m=h+j-k-g),this._splitBarClone.css(c,m),b.preventDefault&&b.preventDefault(),b.stopPropagation&&b.stopPropagation(),!1}return!0},resize:function(a,b){this.width=a,this.height=b,this._arrange()},_resize:function(){var a="horizontal"==this.orientation?"height":"width",b="horizontal"==this.orientation?"top":"left",c=this._splitBarClone.css(b),d=this.host[a](),e=d/100,f=1/e,g=this.panels[0].size;g.toString().indexOf("%")!=-1?(this.panels[0].size=parseFloat(c)*f+"%",this.panels[1].size=100-parseFloat(c)*f+"%"):(this.panels[0].size=parseFloat(c),this.panels[1].size=d-parseFloat(c)),this._layoutPanels(),this._raiseEvent(0,{panels:this.panels})},_stopDrag:function(){if(this._dragging&&this._initOverlay(),this._dragging=!1,this._splitBarClone){if(this.panels[0].collapsed||this.panels[1].collapsed||this.disabled)return!0;this._resize(),this._splitBarClone.remove(),this._splitBarClone=null}},_createSplitBarClone:function(){var a=this.splitBar.clone();return a.fadeTo(0,.7),a.css("z-index",99999),"vertical"==this.orientation?a.css("cursor","col-resize"):a.css("cursor","row-resize"),this.host.append(a),a},_eventName:function(a){return this._isTouchDevice?this._eventsMap[a]:a},_addHandlers:function(){var b=this;if(a.jqx.utilities.resize(this.host,function(){b._layoutPanels()}),this.addHandler(this.splitBar,"dragstart."+this.element.id,function(a){return!1}),this.splitBarButton&&(this.addHandler(this.splitBarButton,"click."+this.element.id,function(){var a=function(a){a.collapsed?b.expand():b.collapse()};b.panels[0].collapsible?a(b.panels[0]):b.panels[1].collapsible&&a(b.panels[1])}),this.addHandler(this.splitBarButton,this._eventName("mouseenter"),function(){b.splitBarButton.addClass(b.toThemeProperty("jqx-splitter-collapse-button-hover")),b.splitBarButton.addClass(b.toThemeProperty("jqx-fill-state-hover"))}),this.addHandler(this.splitBarButton,this._eventName("mouseleave"),function(){b.splitBarButton.removeClass(b.toThemeProperty("jqx-splitter-collapse-button-hover")),b.splitBarButton.removeClass(b.toThemeProperty("jqx-fill-state-hover"))})),this.addHandler(a(document),this._eventName("mousemove")+"."+this.element.id,function(a){return b._drag(a)}),this.addHandler(a(document),this._eventName("mouseup")+"."+this.element.id,function(){return b._stopDrag()}),this.addHandler(this.splitBar,this._eventName("mousedown"),function(a){return b._startDrag(a)}),this.addHandler(this.splitBar,this._eventName("mouseenter"),function(){b.resizable&&!b.disabled&&(b.splitBar.addClass(b.toThemeProperty("jqx-splitter-splitbar-hover")),b.splitBar.addClass(b.toThemeProperty("jqx-fill-state-hover")))}),this.addHandler(this.splitBar,this._eventName("mouseleave"),function(){b.resizable&&!b.disabled&&(b.splitBar.removeClass(b.toThemeProperty("jqx-splitter-splitbar-hover")),b.splitBar.removeClass(b.toThemeProperty("jqx-fill-state-hover")))}),(""!=document.referrer||window.frameElement)&&null!=window.top&&window.top!=window.self){var c=null;if(window.parent&&document.referrer&&(c=document.referrer),c&&c.indexOf(document.location.host)!=-1){var d=function(a){b._stopDrag()};window.top.document.addEventListener?window.top.document.addEventListener("mouseup",d,!1):window.top.document.attachEvent&&window.top.document.attachEvent("onmouseup",d)}}},_removeHandlers:function(){this.removeHandler(a(window),"resize."+this.element.id),this.splitBarButton&&(this.removeHandler(this.splitBarButton,"click."+this.element.id),this.removeHandler(this.splitBarButton,this._eventName("mouseenter")),this.removeHandler(this.splitBarButton,this._eventName("mouseleave"))),this.removeHandler(a(document),this._eventName("mousemove")+"."+this.element.id),this.removeHandler(a(document),this._eventName("mouseup")+"."+this.element.id),this.splitBar&&(this.removeHandler(this.splitBar,"dragstart."+this.element.id),this.removeHandler(this.splitBar,this._eventName("mousedown")),this.removeHandler(this.splitBar,this._eventName("mouseenter")),this.removeHandler(this.splitBar,this._eventName("mouseleave")))},render:function(){this.splitBar&&this.splitBar.remove();var b=this.host.children();if(2!=b.length)throw"Invalid HTML Structure! jqxSplitter requires 1 container DIV tag and 2 nested DIV tags.";if(2==b.length){var c=b[0].className.split(" "),d=b[1].className.split(" ");if(c.indexOf("jqx-reset")!=-1&&c.indexOf("jqx-splitter")!=-1&&c.indexOf("jqx-widget")!=-1)throw"Invalid HTML Structure! Nested jqxSplitter cannot be initialized from a Splitter Panel. You need to add a new DIV tag inside the Splitter Panel and initialize the nested jqxSplitter from it!";if(d.indexOf("jqx-reset")!=-1&&d.indexOf("jqx-splitter")!=-1&&d.indexOf("jqx-widget")!=-1)throw"Invalid HTML Structure! Nested jqxSplitter cannot be initialized from a Splitter Panel. You need to add a new DIV tag inside the Splitter Panel and initialize the nested jqxSplitter from it!"}if(this.host.parent().length>0&&this.host.parent()[0].className.indexOf("jqx-splitter")!=-1){if(this.element.className.indexOf("jqx-splitter-panel")!=-1)throw"Invalid HTML Structure! Nested jqxSplitter cannot be initialized from a Splitter Panel. You need to add a new DIV tag inside the Splitter Panel and initialize the nested jqxSplitter from it!";this._isNested=!0,300==this.width&&(this.width="100%"),300==this.height&&(this.height="100%"),"100%"==this.width&&"100%"==this.height&&(this.host.addClass("jqx-splitter-nested"),this.host.parent()[0].className.indexOf("jqx-splitter-panel")!=-1&&this.host.parent().addClass("jqx-splitter-panel-nested"))}this._hasBorder=0==this.host.hasClass("jqx-hideborder")||""!=this.element.style.borderTopWidth,this._removeHandlers(),this._isTouchDevice=a.jqx.mobile.isTouchDevice(),this._validate(),this.panel1.css("left","0px"),this.panel1.css("top","0px"),this.panel2.css("left","0px"),this.panel2.css("top","0px"),this.splitBar=a("<div><div></div></div>"),this.resizable||this.splitBar.css("cursor","default"),this.splitBarButton=this.splitBar.find("div:last"),this._setTheme(),this.splitBar.insertAfter(this.panel1),this._arrange(),0==this.panels[0].collapsible&&0==this.panels[1].collapsible&&this.splitBarButton.hide();this._addHandlers(),this.initContent&&this.initContent(),this.disabled&&this.disable()},_hiddenParent:function(){return a.jqx.isHidden(this.host)},_setTheme:function(){this.panel1.addClass(this.toThemeProperty("jqx-widget-content")),this.panel2.addClass(this.toThemeProperty("jqx-widget-content")),this.panel1.addClass(this.toThemeProperty("jqx-splitter-panel")),this.panel2.addClass(this.toThemeProperty("jqx-splitter-panel")),this.panel1.addClass(this.toThemeProperty("jqx-reset")),this.panel2.addClass(this.toThemeProperty("jqx-reset")),this.host.addClass(this.toThemeProperty("jqx-reset")),this.host.addClass(this.toThemeProperty("jqx-splitter")),this.host.addClass(this.toThemeProperty("jqx-widget")),this.host.addClass(this.toThemeProperty("jqx-widget-content")),this.splitBar.addClass(this.toThemeProperty("jqx-splitter-splitbar-"+this.orientation)),this.splitBar.addClass(this.toThemeProperty("jqx-fill-state-normal")),this.splitBarButton.addClass(this.toThemeProperty("jqx-splitter-collapse-button-"+this.orientation)),this.splitBarButton.addClass(this.toThemeProperty("jqx-fill-state-pressed"))},_validate:function(){var b=this.host.children();if(2!=b.length)throw"Invalid HTML Structure! jqxSplitter requires two nested DIV tags!";this.panels&&!this.panels[1]?this.panels[0]?this.panels[1]={}:this.panels=[{size:"50%"},{size:"50%"}]:void 0==this.panels&&(this.panels=[{size:"50%"},{size:"50%"}]);var b=this.host.children();this.panel1=this.panels[0].element=a(b[0]),this.panel2=this.panels[1].element=a(b[1]),this.panel1[0].style.minWidth="",this.panel1[0].style.maxWidth="",this.panel2[0].style.minWidth="",this.panel2[0].style.maxWidth="",a.each(this.panels,function(){void 0==this.min&&(this.min=0),void 0==this.size&&(this.size=0),this.size<0&&(this.size=0),this.min<0&&(this.min=0),void 0==this.collapsible&&(this.collapsible=!0),void 0==this.collapsed&&(this.collapsed=!1),0!=this.size&&(this.size.toString().indexOf("px")!=-1&&(this.size=parseInt(this.size)),this.size.toString().indexOf("%")==-1?parseInt(this.min)>parseInt(this.size)&&(this.min=this.size):this.min.toString().indexOf("%")!=-1&&parseInt(this.min)>parseInt(this.size)&&(this.min=this.size))})},_arrange:function(){if(null!=this.width){var a=this.width;"string"!=typeof a&&(a=parseInt(this.width)+"px"),this.host.css("width",a)}if(null!=this.height){var b=this.height;"string"!=typeof b&&(b=parseInt(this.height)+"px"),this.host.css("height",b)}this._splitBarSize=this._isTouchDevice?this.touchSplitBarSize:this.splitBarSize,this.showSplitBar||(this._splitBarSize=0,this.splitBar.hide());var c="horizontal"==this.orientation?"width":"height";this.splitBar.css(c,"100%"),this.panel1.css(c,"100%"),this.panel2.css(c,"100%"),"horizontal"==this.orientation?this.splitBar.height(this._splitBarSize):this.splitBar.width(this._splitBarSize),"vertical"===this.orientation?(this.splitBarButton.width(this._splitBarSize),this.splitBarButton.height(45)):(this.splitBarButton.height(this._splitBarSize),this.splitBarButton.width(45)),this.splitBarButton.css("position","relative"),"vertical"===this.orientation?(this.splitBarButton.css("top","50%"),this.splitBarButton.css("left","0"),this.splitBarButton.css("margin-top","-23px"),this.splitBarButton.css("margin-left","-0px")):(this.splitBarButton.css("left","50%"),this.splitBarButton.css("top","0"),this.splitBarButton.css("margin-left","-23px"),this.splitBarButton.css("margin-top","-0px")),this._layoutPanels()},collapse:function(){if(!this.disabled){var a=-1;this.panels[0].collapsed=this.panels[1].collapsed=!1,this.panels[0].element[0].style.visibility="inherit",this.panels[1].element[0].style.visibility="inherit",this.panels[0].collapsible?a=0:this.panels[1].collapsible&&(a=1),a!=-1&&(this.panels[a].collapsed=!0,this.panels[a].element[0].style.visibility="hidden",this.splitBar.addClass(this.toThemeProperty("jqx-splitter-splitbar-collapsed")),this._layoutPanels(),this._raiseEvent(2,{index:a,panels:this.panels}),this._raiseEvent(0,{panels:this.panels}))}},expand:function(){if(!this.disabled){var a=-1;this.panels[0].collapsed=this.panels[1].collapsed=!1,this.panels[0].element[0].style.visibility="inherit",this.panels[1].element[0].style.visibility="inherit",this.panels[0].collapsible?a=0:this.panels[1].collapsible&&(a=1),a!=-1&&(this.panels[a].collapsed=!1,this.panels[a].element[0].style.visibility="inherit",this.splitBar.removeClass(this.toThemeProperty("jqx-splitter-splitbar-collapsed")),this._layoutPanels(),this._raiseEvent(1,{index:a,panels:this.panels}),this._raiseEvent(0,{panels:this.panels}))}},disable:function(){this.disabled=!0,this.host.addClass(this.toThemeProperty("jqx-fill-state-disabled")),this.splitBar.addClass(this.toThemeProperty("jqx-splitter-splitbar-collapsed")),this.splitBarButton.addClass(this.toThemeProperty("jqx-splitter-splitbar-collapsed"))},enable:function(){this.disabled=!1,this.host.removeClass(this.toThemeProperty("jqx-fill-state-disabled")),this.splitBar.removeClass(this.toThemeProperty("jqx-splitter-splitbar-collapsed")),this.splitBarButton.removeClass(this.toThemeProperty("jqx-splitter-splitbar-collapsed"))},refresh:function(a){1!=a&&this._arrange()},propertyChangedHandler:function(b,c,d,e){return"panels"===c||"orientation"===c||"showSplitBar"===c?void b.render():("touchMode"===c&&(b._isTouchDevice=e),void("disabled"===c?e?b.disable():b.enable():"theme"===c?a.jqx.utilities.setTheme(d,e,b.host):b.refresh()))},_layoutPanels:function(){var a,b,c,d,e=this,f="horizontal"==this.orientation?"height":"width",g="horizontal"==this.orientation?"top":"left",h=parseInt(this._splitBarSize)+2;this.showSplitBar||(h=0);var i=this.host[f](),j=i/100,k=1/j,l=k*h,m=this.panel1,n=this.panel2,o=this.panels[0].size;this.panels[0].collapsed&&(c=!0),this.panels[1].collapsed&&(d=!0),a=this.panels[0].min,b=this.panels[1].min,b.toString().indexOf("%")!=-1&&(b=parseFloat(b)*j),a.toString().indexOf("%")!=-1&&(a=parseFloat(a)*j),this._isNested&&this._isTouchDevice&&("horizontal"==this.orientation?(m.width(this.host.width()),n.width(this.host.width())):(m.height(this.host.height()),n.height(this.host.height())));var p=function(){var a=e.panel1[f]();if(e.splitBar[0].style[g]!=a+"px"){var b=a;"vertical"==e.orientation?(e.splitBar[0].style.borderLeftColor="",e.splitBar[0].style.borderRightColor="",e.splitBarButton[0].style.width=parseInt(e._splitBarSize)+"px",e.splitBarButton[0].style.left="0px"):(e.splitBar[0].style.borderTopColor="",e.splitBar[0].style.borderBottomColor="",e.splitBarButton[0].style.height=parseInt(e._splitBarSize)+"px",e.splitBarButton[0].style.top="0px"),e._hasBorder&&(i-h==a?"vertical"==e.orientation?(e.splitBar[0].style.borderRightColor="transparent",e.splitBarButton[0].style.width=parseInt(e._splitBarSize+1)+"px"):(e.splitBar[0].style.borderBottomColor="transparent",e.splitBarButton[0].style.height=parseInt(e._splitBarSize+1)+"px"):0==a&&("vertical"==e.orientation?(e.splitBar[0].style.borderLeftColor="transparent",e.splitBarButton[0].style.width=parseInt(e._splitBarSize+1)+"px",e.splitBarButton[0].style.left="-1px"):(e.splitBar[0].style.borderTopColor="transparent",e.splitBarButton[0].style.height=parseInt(e._splitBarSize+1)+"px",e.splitBarButton[0].style.top="-1px"))),e.splitBar[0].style[g]=b+"px"}e.panel2[0].style[g]!=a+h+"px"&&(e.panel2[0].style[g]=a+h+"px")};if(c){var q=Math.max(b,i-h);m[f](0),n[f](q)}else if(d){var q=Math.max(a,i-h);n[f](0),m[f](q)}else if(o.toString().indexOf("%")!=-1){var r=100-parseFloat(o);m.css(f,parseFloat(o)+"%"),r-=l,n.css(f,r+"%");var s=n[f]();if(s<b){var q=s-b,t=q*k;o=parseFloat(o)+parseFloat(t);var r=100-parseFloat(o);m.css(f,parseFloat(o)+"%"),r-=l,n.css(f,r+"%")}var u=m[f]();if(u<a){var t=a*k;m.css(f,parseFloat(t)+"%")}}else{var s=i-o-h;m[0].style[f]!=o+"px"&&m[f](o),n[0].style[f]!=s+"px"&&n[f](s),s<b&&(o+=s-b,n[f](b),m[f](o)),o<a&&m[f](a)}p(),this._raiseEvent(4,{panels:this.panels})},destroy:function(){this._removeHandlers(),a.jqx.utilities.resize(this.host,null,!0),this.host.remove()},_raiseEvent:function(b,c){var d=new a.Event(this._events[b]);d.owner=this,d.args=c;var e=("vertical"==this.orientation?"width":"height",new Array);return e[0]={},e[1]={},e[0].size="vertical"==this.orientation?this.panel1[0].offsetWidth:this.panel1[0].offsetHeight,e[1].size="vertical"==this.orientation?this.panel2[0].offsetWidth:this.panel2[0].offsetHeight,e[0].min=this.panels[0].min,e[1].min=this.panels[1].min,e[0].collapsible=this.panels[0].collapsible,e[1].collapsible=this.panels[1].collapsible,e[0].collapsed=this.panels[0].collapsed,e[1].collapsed=this.panels[1].collapsed,d.args.panels=e,this.host.trigger(d)}})}(jqxBaseFramework);

