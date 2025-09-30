// JWT Expiration Timestamp Generator
// Note: JWT "exp" claim uses seconds since epoch, not milliseconds

function generateJWTExpiration(): void {
    // Current time
    const now = new Date();
    
    // Add 5 minutes (5 * 60 * 1000 milliseconds)
    const expirationTime = new Date(now.getTime() + (5 * 60 * 1000));
    
    // JWT exp claim uses seconds since epoch (not milliseconds)
    const jwtExp = Math.floor(expirationTime.getTime() / 1000);
    
    console.log('=== JWT Expiration Generator ===');
    console.log(`Current local time: ${now.toLocaleString()}`);
    console.log(`Expiration time (+5 min): ${expirationTime.toLocaleString()}`);
    console.log(`JWT "exp" value: ${jwtExp}`);
    console.log('');
    console.log('For reference:');
    console.log(`- Current epoch (ms): ${now.getTime()}`);
    console.log(`- Expiration epoch (ms): ${expirationTime.getTime()}`);
    console.log(`- JWT exp (seconds): ${jwtExp}`);
}

// Run the generator
generateJWTExpiration();