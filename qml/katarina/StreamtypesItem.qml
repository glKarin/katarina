import QtQuick 1.1
import com.nokia.meego 1.1

Item{
	id: root;
	signal openUrl(string url, string task_name, string task_value);
	property variant streamModel: ListModel{}
	Flickable{
		id:flickable;
		anchors.fill: parent;
		clip: true;
		contentWidth: width;
		contentHeight: Math.max(height, layout.height);
		Column{
			id:layout;
			width: parent.width;
			Repeater {
				id:repeater;
				model: root.streamModel;
				delegate: Component{
					Item{
						width: layout.width;
						height: grid.height + header.height;
						Column{
							width: parent.width;
							clip: true;
							LineText{
								id: header;
								width: parent.width;
								textColor: "white";
								text: model.task_name + "[" + task_value + "]";
							}
							Grid{
								id: grid;
								property variant submodel: model.transcode;
								property variant task_name: model.task_name;
								property variant task_value: model.task_value;
								columns: 2;
								clip: true;
								width: parent.width;
								Repeater{
									model: grid.submodel;
									delegate: Component{
										Item{
											width: header.width / 2;
											height: 60;
											Text{
												anchors.centerIn: parent;
												font.pixelSize: constants._NormalPixelSize;
												font.family: constants._FontFamily;
												color: "white";
												text: "[" + model.index + "]";
											}
											MouseArea{
												id: mouseArea;
												anchors.fill: parent;
												onClicked:{
													root.openUrl(model.urls, grid.task_name, grid.task_value);
												}
											}
											Rectangle{
												anchors.fill: parent;
												opacity: 0.5;
												color: "white";
												visible: mouseArea.pressed;
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}

	ScrollDecorator{
		flickableItem:flickable;
	}

}
