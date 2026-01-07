// SPDX-License-Identifier: {{license}}

using vm2.MyPackage;

Console.WriteLine("MyPackage example");
Console.WriteLine(MyPackageApi.Echo("hello", "fallback"));
Console.WriteLine(MyPackageApi.Echo(null, "fallback"));
