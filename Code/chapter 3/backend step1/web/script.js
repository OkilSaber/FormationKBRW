window.onload = () => {
    var button = document.querySelector('button');
    button.onclick = () => {
        const elem = React.createElement('div', null, 'Hello World');
        ReactDOM.render(elem, document.querySelector('#root'));
    };
}