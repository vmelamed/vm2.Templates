#!/usr/bin/env dotnet

// SPDX-License-Identifier: {{license}}
// Copyright (c) 2025-2026 Val Melamed

#:property TargetFramework=net10.0
#:project ../src/MyPackage/MyPackage.csproj

using static System.Console;
using static System.Text.Encoding;

using vm2.MyPackage;

using static vm2.MyPackage.MyPackageApi;

Console.WriteLine("MyPackage example");

Console.WriteLine(Echo("hello", "fallback"));
Console.WriteLine(Echo(null, "fallback"));
