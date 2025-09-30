#!/usr/bin/env node

/**
 * Azure DevOps Commit Reporter
 * 
 * Generates a markdown report of commits by a specific author across multiple repositories
 * in an Azure DevOps project over the last 30 days.
 * 
 * Required Environment Variables:
 * - AZURE_PAT: Your Azure DevOps Personal Access Token
 *   Create one at: https://dev.azure.com/{organization}/_usersSettings/tokens
 *   Needs "Code (read)" permission
 * 
 * - AZURE_AUTHOR_EMAIL: Email address of the author whose commits to report
 *   Example: "your.email@company.com"
 * 
 * Optional Environment Variables:
 * - AZURE_ORGANIZATION: Azure DevOps organization name (defaults to "lirio-llc")
 * - AZURE_PROJECT: Project name within the organization (defaults to "Lirio")
 * 
 * Usage:
 *   export AZURE_PAT="your_personal_access_token_here"
 *   export AZURE_AUTHOR_EMAIL="your.email@company.com"
 *   node azure_commit_reporter.ts
 * 
 * Or run with npx/ts-node:
 *   AZURE_PAT="your_pat" AZURE_AUTHOR_EMAIL="your@email.com" npx ts-node azure_commit_reporter.ts
 */

import * as https from 'https';

interface CommitInfo {
  commitId: string;
  author: string;
  date: string;
  comment: string;
  repository: string;
  url: string;
}

interface AzureDevOpsConfig {
  organization: string;
  project: string;
  pat: string; // Personal Access Token
}

class AzureReposCommitReporter {
  private config: AzureDevOpsConfig;
  private baseUrl: string;
  private authHeader: string;

  constructor(config: AzureDevOpsConfig) {
    this.config = config;
    this.baseUrl = `https://dev.azure.com/${config.organization}/${config.project}/_apis`;
    this.authHeader = 'Basic ' + Buffer.from(':' + config.pat).toString('base64');
  }

  private async makeRequest(url: string): Promise<any> {
    return new Promise((resolve, reject) => {
      const options = {
        headers: {
          'Authorization': this.authHeader,
          'Content-Type': 'application/json'
        }
      };

      https.get(url, options, (res) => {
        let data = '';
        res.on('data', (chunk) => { data += chunk; });
        res.on('end', () => {
          if (res.statusCode === 200) {
            resolve(JSON.parse(data));
          } else {
            reject(new Error(`HTTP ${res.statusCode}: ${data}`));
          }
        });
      }).on('error', reject);
    });
  }

  async getRepositories(): Promise<any[]> {
    const url = `${this.baseUrl}/git/repositories?api-version=7.0`;
    const response = await this.makeRequest(url);
    return response.value;
  }

  async getCommitsByAuthor(
    repositoryId: string,
    authorEmail: string,
    fromDate: string,
    toDate: string
  ): Promise<any[]> {
    const url = `${this.baseUrl}/git/repositories/${repositoryId}/commits?searchCriteria.author=${encodeURIComponent(authorEmail)}&searchCriteria.fromDate=${fromDate}&searchCriteria.toDate=${toDate}&api-version=7.0`;
    const response = await this.makeRequest(url);
    return response.value;
  }

  async generateReport(
    authorEmail: string,
    fromDate: string,
    toDate: string
  ): Promise<CommitInfo[]> {
    console.log(`Fetching repositories for project: ${this.config.project}...`);
    const allRepositories = await this.getRepositories();
    
    // Filter to only the repositories we want to search
    const targetRepoNames = [
      'api-gateway',
      'lirio-app-gateway',
      'lirio-atc-prototype',
      'lirio-azure-marketplace',
      'lirio-azure-marketplace-app',
      'lirio-behavioral',
      'lirio-bot',
      'lirio-client',
      'lirio-cms',
      'lirio-common',
      'lirio-common-ui',
      'lirio-communication-manager',
      'lirio-contact',
      'lirio-content',
      'lirio-core-dependencies',
      'lirio-crypto-cli',
      'lirio-dynamics-journeys-plugin',
      'lirio-eligibility',
      'lirio-enterprise-docs',
      'lirio-feedback',
      'lirio-feedback-sim',
      'lirio-gatling-tests',
      'lirio-gradle-plugins',
      'lirio-informant',
      'lirio-infrastructure',
      'lirio-insights',
      'lirio-java-base',
      'lirio-logging-tool',
      'lirio-mailgun-events',
      'lirio-message-delivery-dynamics',
      'lirio-message-delivery-mailgun',
      'lirio-message-delivery-salesforce',
      'lirio-message-delivery-sendgrid',
      'lirio-message-delivery-twilio',
      'lirio-message-templates',
      'lirio-messaging',
      'lirio-ml-feature-store',
      'lirio-orchestration',
      'lirio-platform-data-explorer',
      'lirio-platform-operations',
      'lirio-power-apps-solution',
      'lirio-salesforce-events',
      'lirio-spam-test-tool',
      'lirio-study',
      'lirio-subman',
      'lirio-twilio-events',
      'lirio-twilio-sim',
      'lirio-utils'
    ];
    
    const repositories = allRepositories.filter(repo => 
      targetRepoNames.includes(repo.name)
    );
    
    console.log(`Found ${allRepositories.length} total repositories, filtering to ${repositories.length} target repositories.\n`);

    const allCommits: CommitInfo[] = [];

    for (const repo of repositories) {
      console.log(`Checking repository: ${repo.name}...`);
      try {
        const commits = await this.getCommitsByAuthor(
          repo.id,
          authorEmail,
          fromDate,
          toDate
        );

        for (const commit of commits) {
          allCommits.push({
            commitId: commit.commitId.substring(0, 8),
            author: commit.author.name,
            date: new Date(commit.author.date).toISOString(),
            comment: commit.comment.split('\n')[0], // First line only
            repository: repo.name,
            url: commit.remoteUrl
          });
        }

        console.log(`  Found ${commits.length} commits`);
      } catch (error) {
        console.error(`  Error fetching commits: ${error}`);
      }
    }

    return allCommits.sort((a, b) => 
      new Date(b.date).getTime() - new Date(a.date).getTime()
    );
  }

  generateMarkdownReport(commits: CommitInfo[]): string {
    let markdown = `# Commit Report\n\n`;
    markdown += `**Total Commits:** ${commits.length}\n\n`;
    
    if (commits.length === 0) {
      markdown += `No commits found for the specified criteria.\n`;
      return markdown;
    }

    markdown += `**Author:** ${commits[0].author}\n`;
    markdown += `**Date Range:** ${new Date(commits[commits.length - 1].date).toLocaleDateString()} - ${new Date(commits[0].date).toLocaleDateString()}\n\n`;
    markdown += `---\n\n`;

    // Group by repository
    const byRepo = commits.reduce((acc, commit) => {
      if (!acc[commit.repository]) {
        acc[commit.repository] = [];
      }
      acc[commit.repository].push(commit);
      return acc;
    }, {} as Record<string, CommitInfo[]>);

    for (const [repoName, repoCommits] of Object.entries(byRepo)) {
      markdown += `## ${repoName} (${repoCommits.length} commits)\n\n`;
      
      for (const commit of repoCommits) {
        const date = new Date(commit.date).toLocaleString();
        markdown += `- **[${commit.commitId}](${commit.url})** - ${date}\n`;
        markdown += `  ${commit.comment}\n\n`;
      }
    }

    return markdown;
  }
}

// Usage example
async function main() {
  const config: AzureDevOpsConfig = {
    organization: process.env.AZURE_ORGANIZATION || 'lirio-llc',
    project: process.env.AZURE_PROJECT || 'Lirio',
    pat: process.env.AZURE_PAT || ''
  };

  if (!config.pat) {
    console.error('Error: AZURE_PAT environment variable is required');
    process.exit(1);
  }

  const reporter = new AzureReposCommitReporter(config);

  // Get commits from the last 30 days
  const toDate = new Date().toISOString();
  const fromDate = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString();

  const authorEmail = process.env.AZURE_AUTHOR_EMAIL || 'bmartin@lirio.co';
  if (!authorEmail) {
    console.error('Error: AZURE_AUTHOR_EMAIL environment variable is required');
    process.exit(1);
  }

  try {
    const commits = await reporter.generateReport(
      authorEmail,
      fromDate,
      toDate
    );

    const markdownReport = reporter.generateMarkdownReport(commits);
    console.log('\n' + markdownReport);
    
    // Optionally write to file
    // require('fs').writeFileSync('commit-report.md', markdownReport);
  } catch (error) {
    console.error('Error generating report:', error);
  }
}

// Uncomment to run
main();