#!/bin/bash

# Create core directory structure
mkdir -p lib/core/constants
mkdir -p lib/core/theme
mkdir -p lib/core/utils

# Create data directory structure
mkdir -p lib/data/models/user
mkdir -p lib/data/models/shipment
mkdir -p lib/data/models/delegate
mkdir -p lib/data/models/parcel
mkdir -p lib/data/models/permission
mkdir -p lib/data/models/setting
mkdir -p lib/data/models/login_track
mkdir -p lib/data/repositories
mkdir -p lib/data/services/firebase
mkdir -p lib/data/services/auth
mkdir -p lib/data/services/local

# Create features directory structure
mkdir -p lib/features/auth/controllers
mkdir -p lib/features/auth/screens
mkdir -p lib/features/delegates/controllers
mkdir -p lib/features/delegates/screens
mkdir -p lib/features/shipments/controllers
mkdir -p lib/features/shipments/screens
mkdir -p lib/features/parcels/controllers
mkdir -p lib/features/parcels/screens

# Create shared directory structure
mkdir -p lib/shared/widgets/dashboard
mkdir -p lib/shared/widgets/mobile
mkdir -p lib/shared/widgets/visitor
mkdir -p lib/shared/providers

# Create UI directory structure
mkdir -p lib/ui/dashboard/screens/home
mkdir -p lib/ui/dashboard/screens/auth
mkdir -p lib/ui/dashboard/screens/delegates
mkdir -p lib/ui/dashboard/screens/shipments
mkdir -p lib/ui/dashboard/screens/parcels
mkdir -p lib/ui/dashboard/screens/users
mkdir -p lib/ui/dashboard/screens/settings
mkdir -p lib/ui/dashboard/screens/statistics
mkdir -p lib/ui/mobile/screens/home
mkdir -p lib/ui/mobile/screens/auth
mkdir -p lib/ui/mobile/screens/delegate
mkdir -p lib/ui/mobile/screens/shipments
mkdir -p lib/ui/visitor/screens

# Create README files for each directory
echo -e "# Constants Directory\n\nThis directory contains constant values used throughout the application." > lib/core/constants/README.md
echo -e "# Theme Directory\n\nThis directory contains theme-related files." > lib/core/theme/README.md
echo -e "# Utils Directory\n\nThis directory contains utility functions." > lib/core/utils/README.md

echo -e "# Models Directory\n\nThis directory contains data models." > lib/data/models/README.md
echo -e "# User Models\n\nThis directory contains user-related models." > lib/data/models/user/README.md
echo -e "# Shipment Models\n\nThis directory contains shipment-related models." > lib/data/models/shipment/README.md
echo -e "# Delegate Models\n\nThis directory contains delegate-related models." > lib/data/models/delegate/README.md
echo -e "# Parcel Models\n\nThis directory contains parcel-related models." > lib/data/models/parcel/README.md
echo -e "# Repositories Directory\n\nThis directory contains data repositories." > lib/data/repositories/README.md
echo -e "# Services Directory\n\nThis directory contains data services." > lib/data/services/README.md
echo -e "# Firebase Services\n\nThis directory contains Firebase-related services." > lib/data/services/firebase/README.md
echo -e "# Auth Services\n\nThis directory contains authentication-related services." > lib/data/services/auth/README.md
echo -e "# Local Services\n\nThis directory contains local storage services." > lib/data/services/local/README.md

echo -e "# Auth Feature\n\nThis directory contains authentication-related files." > lib/features/auth/README.md
echo -e "# Auth Controllers\n\nThis directory contains authentication controllers." > lib/features/auth/controllers/README.md
echo -e "# Auth Screens\n\nThis directory contains authentication screens." > lib/features/auth/screens/README.md
echo -e "# Delegates Feature\n\nThis directory contains delegate management files." > lib/features/delegates/README.md
echo -e "# Delegates Controllers\n\nThis directory contains delegate controllers." > lib/features/delegates/controllers/README.md
echo -e "# Delegates Screens\n\nThis directory contains delegate screens." > lib/features/delegates/screens/README.md
echo -e "# Shipments Feature\n\nThis directory contains shipment management files." > lib/features/shipments/README.md
echo -e "# Shipments Controllers\n\nThis directory contains shipment controllers." > lib/features/shipments/controllers/README.md
echo -e "# Shipments Screens\n\nThis directory contains shipment screens." > lib/features/shipments/screens/README.md
echo -e "# Parcels Feature\n\nThis directory contains parcel management files." > lib/features/parcels/README.md
echo -e "# Parcels Controllers\n\nThis directory contains parcel controllers." > lib/features/parcels/controllers/README.md
echo -e "# Parcels Screens\n\nThis directory contains parcel screens." > lib/features/parcels/screens/README.md

echo -e "# Widgets Directory\n\nThis directory contains shared widgets." > lib/shared/widgets/README.md
echo -e "# Dashboard Widgets\n\nThis directory contains dashboard-specific widgets." > lib/shared/widgets/dashboard/README.md
echo -e "# Mobile Widgets\n\nThis directory contains mobile-specific widgets." > lib/shared/widgets/mobile/README.md
echo -e "# Visitor Widgets\n\nThis directory contains visitor-specific widgets." > lib/shared/widgets/visitor/README.md
echo -e "# Providers Directory\n\nThis directory contains shared providers." > lib/shared/providers/README.md

echo -e "# Dashboard UI\n\nThis directory contains dashboard UI files." > lib/ui/dashboard/README.md
echo -e "# Dashboard Home Screens\n\nThis directory contains dashboard home screens." > lib/ui/dashboard/screens/home/README.md
echo -e "# Dashboard Auth Screens\n\nThis directory contains dashboard authentication screens." > lib/ui/dashboard/screens/auth/README.md
echo -e "# Dashboard Delegates Screens\n\nThis directory contains dashboard delegate management screens." > lib/ui/dashboard/screens/delegates/README.md
echo -e "# Dashboard Shipments Screens\n\nThis directory contains dashboard shipment management screens." > lib/ui/dashboard/screens/shipments/README.md
echo -e "# Dashboard Parcels Screens\n\nThis directory contains dashboard parcel management screens." > lib/ui/dashboard/screens/parcels/README.md
echo -e "# Dashboard Users Screens\n\nThis directory contains dashboard user management screens." > lib/ui/dashboard/screens/users/README.md
echo -e "# Dashboard Settings Screens\n\nThis directory contains dashboard settings screens." > lib/ui/dashboard/screens/settings/README.md
echo -e "# Dashboard Statistics Screens\n\nThis directory contains dashboard statistics screens." > lib/ui/dashboard/screens/statistics/README.md
echo -e "# Mobile UI\n\nThis directory contains mobile UI files." > lib/ui/mobile/README.md
echo -e "# Mobile Home Screens\n\nThis directory contains mobile home screens." > lib/ui/mobile/screens/home/README.md
echo -e "# Mobile Auth Screens\n\nThis directory contains mobile authentication screens." > lib/ui/mobile/screens/auth/README.md
echo -e "# Mobile Delegate Screens\n\nThis directory contains mobile delegate screens." > lib/ui/mobile/screens/delegate/README.md
echo -e "# Mobile Shipments Screens\n\nThis directory contains mobile shipment screens." > lib/ui/mobile/screens/shipments/README.md
echo -e "# Visitor UI\n\nThis directory contains visitor UI files." > lib/ui/visitor/README.md
echo -e "# Visitor Screens\n\nThis directory contains visitor screens." > lib/ui/visitor/screens/README.md

echo "Project structure created successfully!"
