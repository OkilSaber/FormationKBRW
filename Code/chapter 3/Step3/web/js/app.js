require('!!file-loader?name=[name].[ext]!../index.html')
require('../webflow/webflow.css');
import {onPathChange} from './utilities';

window.onload = () => {
    onPathChange()
    window.addEventListener("popstate", () => onPathChange());
};