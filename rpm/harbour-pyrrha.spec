# Prevent brp-python-bytecompile from running
%define __os_install_post %{___build_post}

Name:       harbour-pyrrha
Summary:    A Cute Pandora Client
Version:    0.1
Release:    1
Group:      Applications/Multimedia
License:    GPLv3
URL:        https://github.com/corecomic/pyrrha
Source:     %{name}-%{version}.tar.gz
BuildArch:  noarch
Requires:   libsailfishapp-launcher
Requires:   sailfishsilica-qt5 >= 0.10.9
Requires:   pyotherside-qml-plugin-python3-qt5 >= 1.3.0

%description
Pyrrha is a native Pandora Radio client for Sailfish.


%prep
%setup -q -n %{name}-%{version}

%build
# Done

%install
rm -rf %{buildroot}

TARGET=%{buildroot}/%{_datadir}/%{name}
mkdir -p $TARGET
cp -rpv pyrrha* $TARGET/
cp -rpv qml $TARGET/

TARGET=%{buildroot}/%{_datadir}/applications
mkdir -p $TARGET
cp -rpv %{name}.desktop $TARGET/

TARGET=%{buildroot}/%{_datadir}/icons/hicolor/86x86/apps/
mkdir -p $TARGET
cp -rpv %{name}.png $TARGET/


%files
%defattr(-,root,root,-)
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/86x86/apps/%{name}.png

%changelog
# * date Author's Name <author's email> version-release
# - Summary of changes

* Sun Feb 08 2015 Core Comic <core.comic@gmail.com> 0.1-1
- Pre-release build
