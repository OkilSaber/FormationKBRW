require('!!file-loader?name=[name].[ext]!../index.html')
require('../webflow/webflow.css');
require('../webflow/modals.css');
import {onPathChange} from './utilities';

window.onload = () => {
    onPathChange()
    window.addEventListener("popstate", () => onPathChange());
};