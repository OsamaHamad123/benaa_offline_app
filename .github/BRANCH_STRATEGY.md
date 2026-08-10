# 🌳 Git Branching Strategy - Benaa Offline App

## 📋 Overview
This project follows a **simplified Git Flow** workflow designed for professional development teams. Our strategy ensures code quality, easy collaboration, and smooth deployments.

---

## 🎯 Branch Structure

### **Main Branches**

#### `main` - Production Branch
- **Purpose**: Production-ready code only
- **Protection**: Protected, requires PR approval
- **Deployment**: Auto-deploys to production
- **Merge From**: `develop` branch only (via Pull Request)
- **Direct Commits**: ❌ Never commit directly

#### `develop` - Integration Branch
- **Purpose**: Main development integration branch
- **Protection**: Protected, requires PR approval  
- **Testing**: All features must pass CI/CD
- **Merge From**: Feature branches, hotfix branches
- **Merge To**: `main` for releases
- **Direct Commits**: ❌ Avoid direct commits

---

## 🚀 Working Branches

### **Feature Branches**
- **Naming**: `feature/<feature-name>`
- **Created From**: `develop`
- **Merged To**: `develop`
- **Lifetime**: Temporary (delete after merge)
- **Examples**:
  ```
  feature/dashboard-settings
  feature/associations-module
  feature/export-improvements
  ```

### **Bugfix Branches**
- **Naming**: `bugfix/<bug-description>`
- **Created From**: `develop`
- **Merged To**: `develop`
- **Lifetime**: Temporary (delete after merge)
- **Examples**:
  ```
  bugfix/search-crash
  bugfix/form-validation
  ```

### **Hotfix Branches**
- **Naming**: `hotfix/<critical-fix>`
- **Created From**: `main`
- **Merged To**: Both `main` AND `develop`
- **Lifetime**: Temporary (delete after merge)
- **Use Case**: Critical production bugs
- **Examples**:
  ```
  hotfix/crash-on-login
  hotfix/data-corruption
  ```

### **Release Branches** (Optional)
- **Naming**: `release/v<version>`
- **Created From**: `develop`
- **Merged To**: Both `main` AND `develop`
- **Purpose**: Prepare for production release
- **Examples**:
  ```
  release/v1.0.0
  release/v1.1.0
  ```

---

## 📝 Workflow Examples

### 1️⃣ **Creating a New Feature**

```bash
# 1. Update develop
git checkout develop
git pull origin develop

# 2. Create feature branch
git checkout -b feature/new-reports-module

# 3. Work on your feature
git add .
git commit -m "feat: Add advanced reports filtering"

# 4. Push to remote
git push origin feature/new-reports-module

# 5. Create Pull Request on GitHub
# - Target: develop
# - Review: Request code review
# - CI/CD: Ensure all tests pass

# 6. After merge, delete branch
git branch -d feature/new-reports-module
git push origin --delete feature/new-reports-module
```

### 2️⃣ **Hotfix Workflow**

```bash
# 1. Create hotfix from main
git checkout main
git pull origin main
git checkout -b hotfix/fix-critical-crash

# 2. Fix the bug
git add .
git commit -m "fix: Resolve crash on dashboard load"

# 3. Merge to main
git checkout main
git merge hotfix/fix-critical-crash
git push origin main

# 4. Merge to develop
git checkout develop
git merge hotfix/fix-critical-crash
git push origin develop

# 5. Delete hotfix branch
git branch -d hotfix/fix-critical-crash
git push origin --delete hotfix/fix-critical-crash
```

### 3️⃣ **Release Workflow**

```bash
# 1. Create release branch
git checkout develop
git checkout -b release/v1.2.0

# 2. Version bump and final fixes
# - Update pubspec.yaml version
# - Update CHANGELOG.md
# - Fix last-minute bugs

# 3. Merge to main
git checkout main
git merge release/v1.2.0
git tag -a v1.2.0 -m "Release v1.2.0"
git push origin main --tags

# 4. Merge back to develop
git checkout develop
git merge release/v1.2.0
git push origin develop

# 5. Delete release branch
git branch -d release/v1.2.0
```

---

## 🎨 Commit Message Convention

We follow **Conventional Commits** for clear history:

### **Format**
```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

### **Types**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `build`: Build system changes
- `ci`: CI/CD changes
- `chore`: Other changes (dependencies, etc.)

### **Examples**
```bash
git commit -m "feat: Add PDF export for sponsorships"
git commit -m "fix: Resolve null pointer in dashboard stats"
git commit -m "docs: Update API documentation for associations"
git commit -m "refactor: Simplify beneficiary form validation logic"
git commit -m "perf: Optimize database queries for reports"
```

---

## 🔐 Branch Protection Rules

### **`main` Branch**
- ✅ Require pull request before merging
- ✅ Require approvals (1 reviewer minimum)
- ✅ Require status checks to pass
- ✅ Require conversation resolution
- ❌ Do not allow force pushes
- ❌ Do not allow deletions

### **`develop` Branch**
- ✅ Require pull request before merging
- ✅ Require status checks to pass
- ⚠️ Allow administrators to bypass

---

## 🧹 Cleanup Policy

### **After Feature Merge**
1. Delete local branch: `git branch -d feature/<name>`
2. Delete remote branch: `git push origin --delete feature/<name>`

### **Stale Branches**
- Branches inactive for **30+ days** will be reviewed for deletion
- Notify team before deleting shared branches

---

## 📊 Current Branch Status

### **Active Branches**
- `main` - Production (v1.0.1)
- `develop` - Development (latest features)

### **Archived Features**
All previous feature branches have been merged and deleted:
- ✅ kafala_section (Dashboard Settings + Sponsorships)
- ✅ association_section (Associations Module)
- ✅ perf-improvements-nov2025 (Performance Optimizations)
- ✅ refactor_database (Database Refactoring)

---

## 🚦 CI/CD Integration

### **Automated Checks**
- ✅ Flutter analyze
- ✅ Unit tests
- ✅ Integration tests
- ✅ Code coverage (minimum 70%)
- ✅ Build success (Android APK)

### **Auto-Deployment**
- **develop → Firebase App Distribution** (Beta)
- **main → Google Play** (Production)

---

## 📖 References

- [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Flow](https://guides.github.com/introduction/flow/)

---

## 👥 Team Guidelines

1. **Always pull latest** before creating a new branch
2. **Keep branches focused** - one feature per branch
3. **Write descriptive commit messages**
4. **Request reviews** before merging
5. **Delete merged branches** to keep repository clean
6. **Use draft PRs** for work-in-progress
7. **Tag releases** with semantic versioning

---

**Last Updated**: December 20, 2025  
**Maintained By**: Development Team
