#!/usr/bin/env dotnet

// SPDX-License-Identifier: MIT
// Copyright (c) 2025-2026 Val Melamed

#:property TargetFramework=net10.0
#:project ../src/MyPackage/MyPackage.csproj

using static System.Console;

using vm2.MyPackage;

WriteLine("MyPackage example");
WriteLine(MyPackageApi.Echo("hello", "fallback"));
WriteLine(MyPackageApi.Echo(null, "fallback"));
