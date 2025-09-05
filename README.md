# Horda Core for Dart language

[![pub package](https://img.shields.io/pub/v/horda_core.svg)](https://pub.dev/packages/horda_core)
[![License: BSD-3-Clause](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

**Shared foundation for Horda's stateful serverless platform**

Horda Core provides the fundamental types, protocols, and utilities that power the message drive architecture used by both Horda server and client applications.

## Overview

### Key Features

- 🏗️ **Message System**: Strongly typed commands, events, and queries
- 🔍 **Query Framework**: Flexible data querying with nested relationships
- 🔄 **Real-time Synchronization**: Live view updates and change propagation  
- 🌐 **WebSocket Protocol**: Efficient network communication
- 🔧 **Developer Tools**: Comprehensive logging, error handling, and JSON utilities

## Core Architecture

### Message Driven System

Horda Core implements a distributed architecture where components communicate through structured messages:

- **Commands**: Request actions using VerbNoun naming (e.g., `CreateUser`, `UpdateProfile`)
- **Events**: Notify of state changes using NounVerb naming (e.g., `UserCreated`, `ProfileUpdated`)  
- **Queries**: Request data with optional real-time subscriptions
- **Communication Pattern**: Enables loose coupling between clients, entities, and services

### Entity Identification

Every entity in the Horda platform has a unique identifier:

- **EntityId**: Combines entity type and instance identifier
- **Entity Types**: Structured categorization of business domain objects

## Query System

### Query Definitions

Build complex data queries using the fluent query definition API:

- **View Types**: 
  - `Value` - Single typed values (strings, numbers, dates)
  - `Counter` - Integer counters and metrics
  - `Ref` - Links to other entities with attributes
  - `RefList` - Collections of entity references with pagination

- **Query Building**: Programmatic construction with type safety
- **Nested Queries**: Query referenced entities and list items
- **Pagination**: Efficient handling of large datasets with `startAt` and `length` parameters

### Query Results

Retrieve structured data with version tracking:

- **Result Types**: Strongly typed results matching query definitions
- **Change Tracking**: Version information enables efficient synchronization
- **Attributes**: Metadata associated with references and list items
- **Builders**: Programmatic result construction for testing and mocking

## Real-Time Synchronization

### View Changes

Enable live data updates in client applications:

- **Change Types**: View updates, additions, and removals
- **Subscription System**: Real-time data streaming from server to clients
- **Change Propagation**: Automatic updates when entity state changes
- **Efficient Updates**: Only changed data is transmitted

### WebSocket Protocol

Low-latency communication between clients and servers:

- **Message Framing**: Support for both binary and text messages
- **Connection Management**: Robust lifecycle and error handling
- **Protocol Extensions**: Extensible message types for custom needs
- **Performance**: Optimized for high-frequency real-time updates

## Utilities

### JSON Serialization

Efficient data serialization for network transmission:

- **Custom Converters**: Specialized handling for DateTime and Duration objects
- **Type Safety**: Compile-time type checking for serialization
- **Network Optimization**: Compact JSON representation

### Logging

Structured logging system with multiple severity levels:

- **Log Levels**: Trace, Debug, Info, Warn, Error with appropriate use cases
- **Structured Logging**: Consistent subject-message format
- **Simple Logger**: Built-in console-based implementation

## API Reference

### Message System (`message.dart`)

Core message types for entity-command-event communication:

- `RemoteMessage` - Base class for all platform messages
- `RemoteCommand` - Commands that request state changes
- `RemoteEvent` - Events that notify of state changes
- `RemoteQuery` - Queries that request data with optional subscriptions

### Query Framework (`query_def.dart`, `query_res.dart`)

Comprehensive querying system:

- `QueryDef` - Top-level query definitions
- `QueryResult` - Structured query results with change tracking
- `ViewQueryDef`/`ViewQueryResult` - View-specific query types
- Query and result builders for programmatic construction

### View Changes (`view.dart`)

Real-time synchronization system:

- `ViewChange` - Base class for all view changes
- Specific change types for each view type (value, counter, reference, list)
- Change builders and utilities for efficient updates

### Supporting Types

Essential utilities and abstractions:

- `EntityId` - Unique entity identification system
- `Logger` - Structured logging interface and implementations
- `FluirError` - Platform error handling
- JSON converters for DateTime, Duration, and other common types

## Integration

### With horda_server

Horda Core provides the foundation for server-side entity implementation:

- Shared message types ensure type safety between client and server
- Query definitions are executed by server-side entity views
- Real-time changes are propagated through the WebSocket protocol

### With Flutter Apps

Enable real-time UI synchronization in Flutter applications:

- Query results directly bind to Flutter widgets
- View changes trigger automatic UI updates
- Strongly typed messages prevent runtime errors

## License

This project is licensed under the BSD 3-Clause License - see the [LICENSE](LICENSE) file for details.
