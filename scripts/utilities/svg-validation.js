#!/usr/bin/env node

/**
 * SVG Validation Script
 * 
 * This script validates SVG files to ensure they follow the Three Horizons Platform standards.
 * It checks for required elements, accessibility features, and proper structure.
 * 
 * Usage: ./svg-validation.js [options] [file-or-directory]
 * 
 * Options:
 *   --help, -h          Show help
 *   --recursive, -r     Recursively check directories
 *   --fix, -f           Attempt to fix issues (where possible)
 *   --verbose, -v       Show detailed information about each check
 *   --summary, -s       Only show summary of issues
 * 
 * Examples:
 *   ./svg-validation.js assets/images/diagram.svg
 *   ./svg-validation.js -r docs/documentation/architecture/
 *   ./svg-validation.js -f -v assets/images/diagram.svg
 */

const fs = require('fs');
const path = require('path');
const { DOMParser } = require('xmldom');
const chalk = require('chalk') || { green: s => s, red: s => s, yellow: s => s, blue: s => s };

// If chalk is not available, we create a simple polyfill
if (!chalk.green) {
  chalk.green = s => s;
  chalk.red = s => s;
  chalk.yellow = s => s;
  chalk.blue = s => s;
}

// Parse command line arguments
const args = process.argv.slice(2);
let options = {
  recursive: false,
  fix: false,
  verbose: false,
  summary: false,
  target: null
};

for (let i = 0; i < args.length; i++) {
  const arg = args[i];
  if (arg === '--help' || arg === '-h') {
    printHelp();
    process.exit(0);
  } else if (arg === '--recursive' || arg === '-r') {
    options.recursive = true;
  } else if (arg === '--fix' || arg === '-f') {
    options.fix = true;
  } else if (arg === '--verbose' || arg === '-v') {
    options.verbose = true;
  } else if (arg === '--summary' || arg === '-s') {
    options.summary = true;
  } else if (!options.target) {
    options.target = arg;
  }
}

if (!options.target) {
  console.error(chalk.red('Error: No SVG file or directory specified.'));
  printHelp();
  process.exit(1);
}

// Validation requirements based on Three Horizons Platform standards
const requirements = {
  requiredElements: {
    title: {
      check: (doc) => doc.getElementsByTagName('title').length > 0,
      message: 'SVG must have a <title> element for accessibility',
      fix: (content) => {
        // Add a title element if none exists
        if (!/<title/.test(content)) {
          return content.replace(/<svg[^>]*>/, '$&<title>Image Title</title>');
        }
        return content;
      }
    },
    desc: {
      check: (doc) => doc.getElementsByTagName('desc').length > 0,
      message: 'SVG should have a <desc> element for accessibility',
      fix: (content) => {
        // Add a description element if none exists
        if (!/<desc/.test(content)) {
          return content.replace(/<svg[^>]*>/, '$&<desc>Description of the image</desc>');
        }
        return content;
      }
    },
    viewBox: {
      check: (doc) => {
        const svg = doc.getElementsByTagName('svg')[0];
        return svg && svg.hasAttribute('viewBox');
      },
      message: 'SVG must have a viewBox attribute',
      fix: (content) => {
        // Add a default viewBox if none exists
        if (!(/viewBox=/.test(content))) {
          return content.replace(/<svg([^>]*)>/, '<svg$1 viewBox="0 0 800 600">');
        }
        return content;
      }
    }
  },
  accessibility: {
    ariaLabelledBy: {
      check: (doc) => {
        const svg = doc.getElementsByTagName('svg')[0];
        return svg && (svg.hasAttribute('aria-labelledby') || svg.hasAttribute('aria-label'));
      },
      message: 'SVG should have aria-labelledby or aria-label for accessibility',
      fix: (content, doc) => {
        // Add aria-labelledby if there's a title element with id
        const titleMatch = content.match(/<title[^>]*>(.*?)<\/title>/);
        if (titleMatch) {
          const titleContent = titleMatch[1];
          if (!(/aria-labelledby=/.test(content)) && !(/aria-label=/.test(content))) {
            // Add an id to the title element if it doesn't have one
            if (!(/id=/.test(titleMatch[0]))) {
              const titleId = 'svg-title';
              content = content.replace(/<title[^>]*>/, `<title id="${titleId}">`);
              return content.replace(/<svg([^>]*)>/, `<svg$1 aria-labelledby="${titleId}">`);
            }
          }
        }
        return content;
      }
    },
    colorContrast: {
      check: (doc) => {
        // Basic check for text elements with fill attribute
        // A more sophisticated check would analyze contrast ratios
        const textNodes = doc.getElementsByTagName('text');
        let hasAdequateContrast = true;
        
        for (let i = 0; i < textNodes.length; i++) {
          const textNode = textNodes[i];
          if (textNode.hasAttribute('fill') && textNode.getAttribute('fill') === '#fff' && 
              textNode.parentNode && textNode.parentNode.hasAttribute('fill')) {
            const parentFill = textNode.parentNode.getAttribute('fill');
            if (parentFill === '#ffffff' || parentFill === '#fff' || parentFill === 'white') {
              hasAdequateContrast = false;
              break;
            }
          }
        }
        
        return hasAdequateContrast;
      },
      message: 'Text elements should have adequate color contrast with their background',
      fix: null // Too complex to fix automatically
    }
  },
  structure: {
    semanticGroups: {
      check: (doc) => {
        // Check if there are semantic groupings (g elements with id or class)
        const groups = doc.getElementsByTagName('g');
        for (let i = 0; i < groups.length; i++) {
          if (groups[i].hasAttribute('id') || groups[i].hasAttribute('class')) {
            return true;
          }
        }
        return false;
      },
      message: 'SVG should use semantic grouping with <g> elements having id or class attributes',
      fix: null // Too context-dependent to fix automatically
    },
    cssStyles: {
      check: (doc) => {
        // Check if styles are defined in a style element or as CSS classes
        return doc.getElementsByTagName('style').length > 0;
      },
      message: 'SVG should use CSS styles for consistent appearance',
      fix: null // Too complex to fix automatically
    }
  },
  threeHorizonsStyles: {
    colorPalette: {
      check: (doc) => {
        // Check if the SVG uses any of the Three Horizons Platform's colors
        const content = new XMLSerializer().serializeToString(doc);
        return /#0072C6|#24292E|#EE0000|#4CAF50/.test(content);
      },
      message: 'SVG should use the Three Horizons Platform color palette',
      fix: null // Too design-dependent to fix automatically
    },
    fonts: {
      check: (doc) => {
        // Check if any text elements specify Arial or sans-serif fonts
        const textNodes = doc.getElementsByTagName('text');
        for (let i = 0; i < textNodes.length; i++) {
          const style = textNodes[i].getAttribute('style') || '';
          if (/font-family:.*Arial|sans-serif/.test(style)) {
            return true;
          }
        }
        
        // Check if there's a style element with font-family definitions
        const styleElements = doc.getElementsByTagName('style');
        for (let i = 0; i < styleElements.length; i++) {
          const styleContent = styleElements[i].textContent;
          if (/font-family:.*Arial|sans-serif/.test(styleContent)) {
            return true;
          }
        }
        
        return false;
      },
      message: 'SVG should use Arial or sans-serif fonts for consistency',
      fix: null // Too complex to fix automatically
    }
  }
};

// Start validation process
console.log(chalk.blue("=== SVG Validation for Three Horizons Platform ==="));
console.log(`Target: ${options.target}`);
console.log(`Options: ${Object.entries(options).filter(([k, v]) => k !== 'target' && v === true).map(([k]) => k).join(', ') || 'none'}`);
console.log();

const stats = {
  filesChecked: 0,
  filesWithIssues: 0,
  totalIssues: 0,
  issuesByType: {},
  fixedIssues: 0
};

if (fs.existsSync(options.target)) {
  const targetStat = fs.statSync(options.target);
  
  if (targetStat.isFile() && path.extname(options.target).toLowerCase() === '.svg') {
    validateSvgFile(options.target, options, stats);
  } else if (targetStat.isDirectory()) {
    walkDirectory(options.target, options, stats);
  } else {
    console.error(chalk.red(`Error: ${options.target} is not an SVG file or directory.`));
    process.exit(1);
  }
  
  // Print summary
  console.log();
  console.log(chalk.blue("=== Validation Summary ==="));
  console.log(`Files checked: ${stats.filesChecked}`);
  console.log(`Files with issues: ${stats.filesWithIssues}`);
  console.log(`Total issues found: ${stats.totalIssues}`);
  
  if (stats.totalIssues > 0) {
    console.log();
    console.log("Issues by type:");
    Object.entries(stats.issuesByType).forEach(([type, count]) => {
      console.log(`  - ${type}: ${count}`);
    });
  }
  
  if (options.fix && stats.fixedIssues > 0) {
    console.log();
    console.log(`Fixed issues: ${stats.fixedIssues}`);
  }
  
  process.exit(stats.totalIssues > 0 ? 1 : 0);
} else {
  console.error(chalk.red(`Error: ${options.target} does not exist.`));
  process.exit(1);
}

// Functions

function printHelp() {
  console.log(`
SVG Validation Script

This script validates SVG files to ensure they follow the Three Horizons Platform standards.
It checks for required elements, accessibility features, and proper structure.

Usage: ./svg-validation.js [options] [file-or-directory]

Options:
  --help, -h          Show help
  --recursive, -r     Recursively check directories
  --fix, -f           Attempt to fix issues (where possible)
  --verbose, -v       Show detailed information about each check
  --summary, -s       Only show summary of issues

Examples:
  ./svg-validation.js assets/images/diagram.svg
  ./svg-validation.js -r docs/documentation/architecture/
  ./svg-validation.js -f -v assets/images/diagram.svg
  `);
}

function walkDirectory(dirPath, options, stats) {
  const entries = fs.readdirSync(dirPath, { withFileTypes: true });
  
  for (const entry of entries) {
    const fullPath = path.join(dirPath, entry.name);
    
    if (entry.isDirectory()) {
      if (options.recursive) {
        walkDirectory(fullPath, options, stats);
      }
    } else if (entry.isFile() && path.extname(entry.name).toLowerCase() === '.svg') {
      validateSvgFile(fullPath, options, stats);
    }
  }
}

function validateSvgFile(filePath, options, stats) {
  if (!options.summary) {
    console.log(chalk.blue(`Checking ${filePath}...`));
  }
  
  try {
    let svgContent = fs.readFileSync(filePath, 'utf8');
    let fileIssues = 0;
    let fixedFileIssues = 0;
    let contentModified = false;
    
    // Parse the SVG
    const parser = new DOMParser();
    let doc = parser.parseFromString(svgContent, 'text/xml');
    
    // Check all requirements
    for (const [category, checks] of Object.entries(requirements)) {
      if (options.verbose && !options.summary) {
        console.log(`Checking ${category}...`);
      }
      
      for (const [checkName, check] of Object.entries(checks)) {
        const passed = check.check(doc);
        
        if (!passed) {
          fileIssues++;
          stats.totalIssues++;
          
          // Track issue by type
          const issueType = `${category}.${checkName}`;
          stats.issuesByType[issueType] = (stats.issuesByType[issueType] || 0) + 1;
          
          if (!options.summary) {
            console.log(chalk.red(`❌ [${category}.${checkName}] ${check.message}`));
          }
          
          // Try to fix the issue if requested and if a fix is available
          if (options.fix && check.fix) {
            const fixedContent = check.fix(svgContent, doc);
            if (fixedContent !== svgContent) {
              svgContent = fixedContent;
              contentModified = true;
              fixedFileIssues++;
              stats.fixedIssues++;
              
              if (!options.summary) {
                console.log(chalk.green(`  ✓ Fixed: ${check.message}`));
              }
              
              // Re-parse the content
              doc = parser.parseFromString(svgContent, 'text/xml');
            }
          }
        } else if (options.verbose && !options.summary) {
          console.log(chalk.green(`✓ [${category}.${checkName}] Passed`));
        }
      }
    }
    
    // Save changes if content was modified
    if (contentModified) {
      fs.writeFileSync(filePath, svgContent, 'utf8');
    }
    
    // Update stats
    stats.filesChecked++;
    if (fileIssues > 0) {
      stats.filesWithIssues++;
    }
    
    // Print file summary
    if (!options.summary) {
      if (fileIssues === 0) {
        console.log(chalk.green(`✓ No issues found in ${filePath}`));
      } else {
        console.log(`Issues found: ${fileIssues}${fixedFileIssues > 0 ? `, Fixed: ${fixedFileIssues}` : ''}`);
      }
      console.log();
    }
  } catch (error) {
    console.error(chalk.red(`Error processing ${filePath}: ${error.message}`));
    stats.filesChecked++;
    stats.filesWithIssues++;
  }
} 