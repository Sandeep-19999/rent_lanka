import test from 'node:test';
import assert from 'node:assert/strict';
import { build } from 'esbuild';
import { mkdir, writeFile, rm } from 'node:fs/promises';
import { pathToFileURL } from 'node:url';
import path from 'node:path';
import { createElement } from 'react';
import { renderToStaticMarkup } from 'react-dom/server';
import { photoState } from '../src/utils/photoState.js';

test('photo loading clears on success and failed images switch to error', () => {
  assert.equal(photoState('loading','load'),'loaded');
  assert.equal(photoState('loading','error'),'error');
  assert.equal(photoState('loaded','error'),'error');
});
test('photo component renders missing state, real URL and accessible original-image link', async () => {
  const directory = path.resolve('node_modules/.cache/rent-lanka-photo-tests');
  await mkdir(directory,{recursive:true});
  const target = path.join(directory,`photo-${process.pid}.mjs`);
  const bundle = await build({ entryPoints:['src/components/common/StoredPhoto.jsx'],bundle:true,write:false,platform:'node',format:'esm',jsx:'automatic',external:['react','react/jsx-runtime'] });
  await writeFile(target,bundle.outputFiles[0].text);
  try {
    const { default: Photo } = await import(pathToFileURL(target).href);
    assert.match(renderToStaticMarkup(createElement(Photo,{src:'',alt:'Equipment'})),/No photo uploaded/);
    assert.doesNotMatch(renderToStaticMarkup(createElement(Photo,{src:'javascript:alert(1)',alt:'Equipment'})),/<img/);
    const url='https://res.cloudinary.com/gg8wheuw/image/upload/test.jpg';
    const markup=renderToStaticMarkup(createElement(Photo,{src:url,alt:'Cricket bat',enlarge:true}));
    assert.ok(markup.includes(url)); assert.match(markup,/Loading photo/); assert.match(markup,/alt="Cricket bat"/); assert.match(markup,/noopener noreferrer/);
  } finally { await rm(target); }
});
