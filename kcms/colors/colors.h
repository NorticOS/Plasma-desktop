/*
 * Copyright (c) 2019 Kai Uwe Broulik <kde@privat.broulik.de>
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

#pragma once

#include <QScopedPointer>
#include <QPointer>

#include <KSharedConfig>

#include <KNewStuff3/KNS3/DownloadDialog>

#include <KQuickAddons/ConfigModule>

class QProcess;
class QTemporaryFile;

namespace KIO
{
class FileCopyJob;
}

class ColorsModel;
class FilterProxyModel;

class KCMColors : public KQuickAddons::ConfigModule
{
    Q_OBJECT

    Q_PROPERTY(ColorsModel *model READ model CONSTANT)
    Q_PROPERTY(FilterProxyModel *filteredModel READ filteredModel CONSTANT)
    Q_PROPERTY(bool downloadingFile READ downloadingFile NOTIFY downloadingFileChanged)

public:
    KCMColors(QObject *parent, const QVariantList &args);
    ~KCMColors() override;

    enum Roles {
        SchemeNameRole = Qt::UserRole + 1,
        PaletteRole,
        RemovableRole,
        PendingDeletionRole
    };

    enum SchemeFilter {
        AllSchemes,
        LightSchemes,
        DarkSchemes
    };
    Q_ENUM(SchemeFilter)

    ColorsModel *model() const;
    FilterProxyModel *filteredModel() const;

    bool downloadingFile() const;

    Q_INVOKABLE void getNewStuff(QQuickItem *ctx);
    Q_INVOKABLE void installSchemeFromFile(const QUrl &url);

    Q_INVOKABLE void editScheme(const QString &schemeName, QQuickItem *ctx);

public Q_SLOTS:
    void load() override;
    void save() override;
    void defaults() override;

Q_SIGNALS:
    void selectedSchemeChanged();
    void selectedSchemeIndexChanged();
    void downloadingFileChanged();

    void showSuccessMessage(const QString &message);
    void showErrorMessage(const QString &message);

    void showSchemeNotInstalledWarning(const QString &schemeName);

private:
    void saveColors();
    void processPendingDeletions();

    void installSchemeFile(const QString &path);

    ColorsModel *m_model;
    FilterProxyModel *m_filteredModel;

    bool m_selectedSchemeDirty = false;

    bool m_applyToAlien = true;

    QPointer<KNS3::DownloadDialog> m_newStuffDialog;

    QProcess *m_editDialogProcess = nullptr;

    KSharedConfigPtr m_config;

    QScopedPointer<QTemporaryFile> m_tempInstallFile;
    QPointer<KIO::FileCopyJob> m_tempCopyJob;

};
