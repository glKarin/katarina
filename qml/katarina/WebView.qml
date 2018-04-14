import QtQuick 1.1
import com.nokia.meego 1.1
import KatarinaWebKit 1.0

Item{
	id: root;
	property alias url: webview.url;
	property alias title: webview.title;
	property alias progress: webview.progress;
	property alias reload: webview.reload;
	property alias stop: webview.stop;
	property alias back: webview.back;
	property alias forward: webview.forward;
	property alias icon: webview.icon;

	signal linkClicked(url link);
	signal alert(string message);

	Flickable{
		id:flick;
		anchors.fill: parent;
		contentWidth: Math.max(width,webview.width);
		contentHeight: Math.max(height,webview.height);
		//flickableDirection: Flickable.VerticalFlick;
		clip:true;
		KatarinaWebView{
			id:webview;
			preferredWidth: flick.width;
			preferredHeight: flick.height;
			settings.autoLoadImages: true;
			settings.offlineStorageDatabaseEnabled : true;
			settings.offlineWebApplicationCacheEnabled : true;
			settings.localStorageDatabaseEnabled : true;
			onLinkClicked:{
				root.linkClicked(link);
			}
			onAlert:{
				root.alert(message);
			}
			onLoadStarted: {
				flick.contentX = 0
				flick.contentY = 0
			}
		}
	}
	ProgressBar{
		anchors{
			top: flick.top;
			leftMargin:40;
			rightMargin:40;
			left:parent.left;
			right:parent.right;
			topMargin:0 - height / 2;
		}
		maximumValue: 1;
		minimumValue: 0;
		value: webview.progress;
		visible: value !== 1.0;
		z: 1;
		clip: true;
	}
	ScrollDecorator{
		flickableItem:flick;
	}
}
