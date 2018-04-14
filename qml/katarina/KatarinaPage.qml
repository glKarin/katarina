import com.nokia.meego 1.1

Page{
	id: root;
	property alias indicating: indicator.visible;
	property alias title: header.title;
	property alias headerHeight: header.height;
	property alias headerBottom: header.bottom;
	
	orientationLock: settings.lockOrientation === "portrait" ? PageOrientation.LockPortrait : settings.lockOrientation === "landscape"? PageOrientation.LockLandscape : PageOrientation.Automatic;

	HeaderView{
		id:header;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.top: parent.top;
	}

	BusyIndicator{
		id:indicator;
		anchors.centerIn:parent;
		z:3;
		platformStyle:BusyIndicatorStyle{
			size:"large";
		}
		visible:false;
		running:visible;
	}
}

