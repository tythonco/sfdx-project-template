/**
 * Collection of Methods to help in styling LWCs
 * Author: Tython
 * Last Modified: 6/15/2021
 */

/**
 * Workaround for overriding style rules in child components "hidden" by Shadow DOM
 *  Credit: https://salesforce.stackexchange.com/a/270624/68974
 *
 * @param {Object} cmp, a reference to an LWC, injection target
 * @param {String} selector, a CSS selector targeting a specific element
 * @param {String} styles, a string of CSS to inject into the component
 */
const injectStylesLWC = ({ cmp, selector, styles }) => {
    const style = document.createElement('style');
    style.innerText = styles;
    cmp.template.querySelector(selector).appendChild(style);
};

export { injectStylesLWC };
