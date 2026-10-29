import { existsSync, readdirSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import { Config } from "@remotion/cli/config";

Config.setEntryPoint("./remotion/src/index.ts");
Config.setVideoImageFormat("jpeg");
Config.setOverwriteOutput(true);

// Remotion downloads its own Chrome Headless Shell from remotion.media. When that
// host is unreachable (offline/sandboxed machines), reuse the one HyperFrames
// installs with `npx hyperframes browser ensure`. REMOTION_BROWSER_EXECUTABLE wins.
const findHyperframesChrome = (): string | null => {
  const root = join(homedir(), ".cache/hyperframes/chrome/chrome-headless-shell");
  if (!existsSync(root)) return null;
  for (const version of readdirSync(root).sort().reverse()) {
    const bin = join(root, version, "chrome-headless-shell-linux64/chrome-headless-shell");
    if (existsSync(bin)) return bin;
  }
  return null;
};

const browser = process.env.REMOTION_BROWSER_EXECUTABLE || findHyperframesChrome();
if (browser) Config.setBrowserExecutable(browser);
