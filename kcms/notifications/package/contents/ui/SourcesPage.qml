/*
 * Copyright 2019 Kai Uwe Broulik <kde@privat.broulik.de>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.3 as QtControls

import org.kde.kirigami 2.8 as Kirigami
import org.kde.kcm 1.2 as KCM

import org.kde.private.kcms.notifications 1.0 as Private

Kirigami.Page {
    id: sourcesPage
    title: i18n("Application Settings")

    Component.onCompleted: {
        kcm.sourcesModel.load();

        var idx = kcm.sourcesModel.persistentIndexForDesktopEntry(kcm.initialDesktopEntry);
        if (!idx.valid) {
            idx = kcm.sourcesModel.persistentIndexForNotifyRcName(kcm.initialNotifyRcName);
        }
        appConfiguration.rootIndex = idx;

        // In Component.onCompleted we might not be assigned a window yet
        // which we need to make the events config dialog transient to it
        Qt.callLater(function() {
            if (kcm.initialEventId && kcm.initialNotifyRcName) {
                appConfiguration.configureEvents(kcm.initialEventId);
            }

            kcm.initialDesktopEntry = "";
            kcm.initialNotifyRcName = "";
            kcm.initialEventId = "";
        });
    }

    Binding {
        target: kcm.filteredModel
        property: "query"
        value: searchField.text
    }

    // We need to manually keep track of the index as we store the sourceModel index
    // and then use a proxy model to filter it. We don't get any QML change signals anywhere
    // and ListView needs a currentIndex number
    Connections {
        target: kcm.filteredModel
        onRowsRemoved: sourcesList.updateCurrentIndex()
        onRowsInserted: sourcesList.updateCurrentIndex()
        // TODO re-create model index if possible
        onModelReset: appConfiguration.rootIndex = undefined
    }

    RowLayout {
        id: rootRow
        anchors.fill: parent

        ColumnLayout {
            Layout.minimumWidth: Kirigami.Units.gridUnit * 12
            Layout.preferredWidth: Math.round(rootRow.width / 3)

            Kirigami.SearchField {
                id: searchField
                Layout.fillWidth: true
            }

            QtControls.ScrollView {
                id: sourcesScroll
                Layout.fillWidth: true
                Layout.fillHeight: true
                activeFocusOnTab: false
                Kirigami.Theme.colorSet: Kirigami.Theme.View
                Kirigami.Theme.inherit: false

                Component.onCompleted: background.visible = true

                ListView {
                    id: sourcesList
                    clip: true
                    activeFocusOnTab: true

                    keyNavigationEnabled: true
                    keyNavigationWraps: true
                    highlightMoveDuration: 0

                    model: kcm.filteredModel
                    currentIndex: -1

                    section {
                        criteria: ViewSection.FullString
                        property: "sourceType"
                        delegate: QtControls.ItemDelegate {
                            id: sourceSection
                            width: sourcesList.width
                            text: {
                                switch (Number(section)) {
                                case Private.SourcesModel.ApplicationType: return i18n("Applications");
                                case Private.SourcesModel.ServiceType: return i18n("System Services");
                                }
                            }

                            // unset "disabled" text color...
                            contentItem: QtControls.Label {
                                text: sourceSection.text
                                // FIXME why does none of this work :(
                                //Kirigami.Theme.colorGroup: Kirigami.Theme.Active
                                //color: Kirigami.Theme.textColor
                                color: rootRow.Kirigami.Theme.textColor
                                elide: Text.ElideRight
                                verticalAlignment: Text.AlignVCenter
                            }
                            enabled: false
                        }
                    }

                    // We need to manually keep track of the index when we filter
                    function updateCurrentIndex() {
                        if (!appConfiguration.rootIndex || !appConfiguration.rootIndex.valid) {
                            currentIndex = -1;
                            return;
                        }

                        var filteredIdx = kcm.filteredModel.mapFromSource(appConfiguration.rootIndex);
                        if (!filteredIdx.valid) {
                            currentIndex = -1;
                            return;
                        }

                        currentIndex = filteredIdx.row;
                    }

                    delegate: QtControls.ItemDelegate {
                        id: sourceDelegate
                        width: sourcesList.width
                        text: model.display
                        highlighted: ListView.isCurrentItem
                        onClicked: {
                            var sourceIdx = kcm.filteredModel.mapToSource(kcm.filteredModel.index(index, 0));
                            appConfiguration.rootIndex = kcm.sourcesModel.makePersistentModelIndex(sourceIdx);
                            sourcesList.updateCurrentIndex();
                        }

                        contentItem: RowLayout {
                            Kirigami.Icon {
                                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                                Layout.preferredHeight: Kirigami.Units.iconSizes.small
                                source: model.decoration
                            }

                            QtControls.Label {
                                Layout.fillWidth: true
                                text: sourceDelegate.text
                                font: sourceDelegate.font
                                color: sourceDelegate.highlighted || sourceDelegate.checked || (sourceDelegate.pressed && !sourceDelegate.checked && !sourceDelegate.sectionDelegate) ? Kirigami.Theme.highlightedTextColor : (sourceDelegate.enabled ? Kirigami.Theme.textColor : Kirigami.Theme.disabledTextColor)
                                elide: Text.ElideRight
                                textFormat: Text.PlainText
                            }
                        }
                    }

                    QtControls.Label {
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            right: parent.right
                            margins: Kirigami.Units.smallSpacing
                        }
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        text: i18n("No application or event matches your search term.")
                        visible: sourcesList.count === 0 && searchField.length > 0
                        enabled: false
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: Math.round(rootRow.width / 3 * 2)

            ApplicationConfiguration {
                id: appConfiguration
                anchors.fill: parent
                onRootIndexChanged: sourcesList.updateCurrentIndex()
                visible: typeof appConfiguration.rootIndex !== "undefined" && appConfiguration.rootIndex.valid
            }

            QtControls.Label {
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    right: parent.right
                    margins: Kirigami.Units.smallSpacing
                }
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: i18n("Select an application from the list to configure its notification settings and behavior.")
                visible: !appConfiguration.rootIndex || !appConfiguration.rootIndex.valid
            }
        }
    }
}
