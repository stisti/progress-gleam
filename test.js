let count = 0

function generateRandomText(length) {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 ';
    let result = '';
    const maxLength = Math.min(length, 40);
    
    for (let i = 0; i < maxLength; i++) {
        result += characters.charAt(Math.floor(Math.random() * characters.length));
    }
    return result;
}

function printRandomLine() {
    const text = generateRandomText(40);
    console.log(text);
    count++;
}

// Print a line every 5 seconds
const interval = setInterval(() => {
    printRandomLine();
    if (count >= 5) {
        clearInterval(interval);
    }
}, 5000);

// Print first line immediately
printRandomLine();
