import { readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";

const root = resolve(import.meta.dirname, "..");
const source = (path) => readFileSync(resolve(root, path), "utf8").replaceAll("]]>", "]] ]]><![CDATA[>");
const id = (() => { let value = 0; return () => `RBX${++value}`; })();
const script = (className, name, path) => `<Item class="${className}" referent="${id()}"><Properties><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${source(path)}]]></ProtectedString><string name="Name">${name}</string></Properties></Item>`;
const folder = (className, name, children) => `<Item class="${className}" referent="${id()}"><Properties><string name="Name">${name}</string></Properties>${children}</Item>`;

const shared = folder("Folder", "Shared", script("ModuleScript", "Config", "src/shared/Config.lua"));
const replicatedStorage = folder("ReplicatedStorage", "ReplicatedStorage", shared);
const serverScriptService = folder("ServerScriptService", "ServerScriptService", script("Script", "GameServer", "src/server/GameServer.server.lua"));
const starterScripts = folder("StarterPlayerScripts", "StarterPlayerScripts", script("LocalScript", "GameClient", "src/client/GameClient.client.lua"));
const starterPlayer = folder("StarterPlayer", "StarterPlayer", starterScripts);
const workspace = folder("Workspace", "Workspace", "");

const xml = `<?xml version="1.0" encoding="utf-8"?>
<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="4">
  <External>null</External><External>nil</External>
  ${workspace}${replicatedStorage}${serverScriptService}${starterPlayer}
</roblox>`;

writeFileSync(resolve(root, "StealAnEgg.rbxlx"), xml);
console.log("StealAnEgg.rbxlx criado com sucesso.");
