/* Entry for the shared site bar. Runs before the page bundle. */

import { catalog } from "../catalog";
import { mountSiteBar } from "../core/site";

mountSiteBar(catalog);
