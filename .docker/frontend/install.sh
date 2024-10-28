#!/usr/bin/env bash

npm create vite@latest frontend -- --template react-ts <<< 'y'

npm install react-router-dom axios @tanstack/react-query
npm i mdb-react-ui-kit @fortawesome/fontawesome-free
npm install -D sass

#npm install -D vitest @testing-library/react @testing-library/jest-dom @testing-library/user-event jsdom
#npm i --save-dev jest ts-node ts-jest @types/jest jest-environment-jsdom

sed -i 's|"dev": "vite"|"dev": "vite --host=0.0.0.0 --port=3000"|' ./frontend/package.json

chmod -R a+rw frontend

rsync -a frontend/ ./
rm -rf frontend