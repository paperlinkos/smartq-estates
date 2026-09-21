import '../models/gas_request.dart';
import '../models/generator_request.dart';
import '../models/grocery_request.dart';
import '../models/maintenance_request.dart';
import '../models/market_run_request.dart';
import '../models/petrol_request.dart';
import '../models/service_request_item.dart';
import '../repositories/gas_repository.dart';
import '../repositories/generator_repository.dart';
import '../repositories/grocery_repository.dart';
import '../repositories/maintenance_repository.dart';
import '../repositories/market_run_repository.dart';
import '../repositories/petrol_repository.dart';

/// An aggregating coordinator that unifies access across all six independent estate service domains.
///
/// Provides centralized listing, filtering (Active vs History), and status management
/// for both Resident views (My Requests) and Estate Operations staff (Operations Desk)
/// while maintaining domain decoupling and clean repository abstractions.
class ServiceCoordinator {
  final MarketRunRepository marketRunRepo;
  final GroceryRepository groceryRepo;
  final GasRepository gasRepo;
  final PetrolRepository petrolRepo;
  final GeneratorRepository generatorRepo;
  final MaintenanceRepository maintenanceRepo;

  ServiceCoordinator({
    required this.marketRunRepo,
    required this.groceryRepo,
    required this.gasRepo,
    required this.petrolRepo,
    required this.generatorRepo,
    required this.maintenanceRepo,
  });

  /// The application-wide shared singleton instance.
  static final ServiceCoordinator instance = ServiceCoordinator(
    marketRunRepo: LocalMarketRunRepository.instance,
    groceryRepo: LocalGroceryRepository.instance,
    gasRepo: LocalGasRepository.instance,
    petrolRepo: LocalPetrolRepository.instance,
    generatorRepo: LocalGeneratorRepository.instance,
    maintenanceRepo: LocalMaintenanceRepository.instance,
  );

  /// Factory helper for creating test-isolated coordinators with custom or test repositories.
  factory ServiceCoordinator.testInstance({
    MarketRunRepository? marketRunRepo,
    GroceryRepository? groceryRepo,
    GasRepository? gasRepo,
    PetrolRepository? petrolRepo,
    GeneratorRepository? generatorRepo,
    MaintenanceRepository? maintenanceRepo,
  }) {
    return ServiceCoordinator(
      marketRunRepo: marketRunRepo ?? LocalMarketRunRepository.testInstance(),
      groceryRepo: groceryRepo ?? LocalGroceryRepository.testInstance(),
      gasRepo: gasRepo ?? LocalGasRepository.testInstance(),
      petrolRepo: petrolRepo ?? LocalPetrolRepository.testInstance(),
      generatorRepo: generatorRepo ?? LocalGeneratorRepository.testInstance(),
      maintenanceRepo:
          maintenanceRepo ?? LocalMaintenanceRepository.testInstance(),
    );
  }

  /// Returns all estate service requests across all domains, sorted by creation date descending.
  List<ServiceRequestItem> getAllRequests() {
    final list = <ServiceRequestItem>[
      ...marketRunRepo.getRequests(),
      ...groceryRepo.getRequests(),
      ...gasRepo.getRequests(),
      ...petrolRepo.getRequests(),
      ...generatorRepo.getRequests(),
      ...maintenanceRepo.getRequests(),
    ];
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(list);
  }

  /// Returns all actively pending or processing requests (not completed or cancelled).
  List<ServiceRequestItem> getActiveRequests() {
    final all = getAllRequests();
    return List.unmodifiable(all.where((r) => r.isActive));
  }

  /// Returns all finished or historical requests (completed, delivered, or cancelled).
  List<ServiceRequestItem> getCompletedRequests() {
    final all = getAllRequests();
    return List.unmodifiable(all.where((r) => !r.isActive));
  }

  /// Retrieves a specific request by its unique [id] across all repositories.
  ServiceRequestItem? getRequestById(String id) {
    if (id.startsWith('MR-')) return marketRunRepo.getRequestById(id);
    if (id.startsWith('GR-')) return groceryRepo.getRequestById(id);
    if (id.startsWith('GAS-')) return gasRepo.getRequestById(id);
    if (id.startsWith('PETROL-')) return petrolRepo.getRequestById(id);
    if (id.startsWith('GEN-')) return generatorRepo.getRequestById(id);
    if (id.startsWith('MAINT-')) return maintenanceRepo.getRequestById(id);

    // Fallback search across all
    for (final r in getAllRequests()) {
      if (r.id == id) return r;
    }
    return null;
  }

  /// Resident cancellation action: cancels request only if still in intake `requested` state.
  bool cancelRequest(String id) {
    if (id.startsWith('MR-')) return marketRunRepo.cancelRequest(id);
    if (id.startsWith('GR-')) return groceryRepo.cancelRequest(id);
    if (id.startsWith('GAS-')) return gasRepo.cancelRequest(id);
    if (id.startsWith('PETROL-')) return petrolRepo.cancelRequest(id);
    if (id.startsWith('GEN-')) return generatorRepo.cancelRequest(id);
    if (id.startsWith('MAINT-')) return maintenanceRepo.cancelRequest(id);

    return false;
  }

  /// Returns requests filtered for a specific resident (e.g., for RLS simulation).
  List<ServiceRequestItem> getRequestsForResident(String residentId) {
    return List.unmodifiable(
      getAllRequests().where((r) => r.residentId == residentId),
    );
  }

  /// Management action: transitions a request directly from intake `requested` to active `inProgress`.
  bool startRequest(String id) {
    final item = getRequestById(id);
    if (item == null || item.operationalPhase != ServiceOperationalPhase.requested) {
      return false;
    }

    if (id.startsWith('MR-')) {
      marketRunRepo.updateStatus(id, MarketRunStatus.shopping);
      return true;
    }
    if (id.startsWith('GR-')) {
      groceryRepo.updateStatus(id, GroceryRequestStatus.shopping);
      return true;
    }
    if (id.startsWith('GAS-')) {
      gasRepo.updateStatus(id, GasRequestStatus.refilling);
      return true;
    }
    if (id.startsWith('PETROL-')) {
      petrolRepo.updateStatus(id, PetrolRequestStatus.refuelling);
      return true;
    }
    if (id.startsWith('GEN-')) {
      generatorRepo.updateStatus(id, GeneratorRequestStatus.inProgress);
      return true;
    }
    if (id.startsWith('MAINT-')) {
      maintenanceRepo.updateStatus(id, MaintenanceRequestStatus.inProgress);
      return true;
    }
    return false;
  }

  /// Management action: transitions an active request to final `completed` (or `delivered`).
  bool completeRequest(String id) {
    final item = getRequestById(id);
    if (item == null || !item.isActive) {
      return false;
    }

    if (id.startsWith('MR-')) {
      marketRunRepo.updateStatus(id, MarketRunStatus.delivered);
      return true;
    }
    if (id.startsWith('GR-')) {
      groceryRepo.updateStatus(id, GroceryRequestStatus.delivered);
      return true;
    }
    if (id.startsWith('GAS-')) {
      gasRepo.updateStatus(id, GasRequestStatus.delivered);
      return true;
    }
    if (id.startsWith('PETROL-')) {
      petrolRepo.updateStatus(id, PetrolRequestStatus.delivered);
      return true;
    }
    if (id.startsWith('GEN-')) {
      generatorRepo.updateStatus(id, GeneratorRequestStatus.completed);
      return true;
    }
    if (id.startsWith('MAINT-')) {
      maintenanceRepo.updateStatus(id, MaintenanceRequestStatus.completed);
      return true;
    }
    return false;
  }

  /// Operations transition: advances request from `requested` -> operational phase -> `completed`/`delivered`.
  bool advanceStatus(String id) {
    if (id.startsWith('MR-')) {
      final req = marketRunRepo.getRequestById(id);
      if (req == null) return false;
      switch (req.status) {
        case MarketRunStatus.requested:
          marketRunRepo.updateStatus(id, MarketRunStatus.assigned);
          return true;
        case MarketRunStatus.assigned:
          marketRunRepo.updateStatus(id, MarketRunStatus.shopping);
          return true;
        case MarketRunStatus.shopping:
          marketRunRepo.updateStatus(id, MarketRunStatus.outForDelivery);
          return true;
        case MarketRunStatus.outForDelivery:
          marketRunRepo.updateStatus(id, MarketRunStatus.delivered);
          return true;
        case MarketRunStatus.delivered:
        case MarketRunStatus.cancelled:
          return false;
      }
    }

    if (id.startsWith('GR-')) {
      final req = groceryRepo.getRequestById(id);
      if (req == null) return false;
      switch (req.status) {
        case GroceryRequestStatus.requested:
          groceryRepo.updateStatus(id, GroceryRequestStatus.assigned);
          return true;
        case GroceryRequestStatus.assigned:
          groceryRepo.updateStatus(id, GroceryRequestStatus.shopping);
          return true;
        case GroceryRequestStatus.shopping:
          groceryRepo.updateStatus(id, GroceryRequestStatus.outForDelivery);
          return true;
        case GroceryRequestStatus.outForDelivery:
          groceryRepo.updateStatus(id, GroceryRequestStatus.delivered);
          return true;
        case GroceryRequestStatus.delivered:
        case GroceryRequestStatus.cancelled:
          return false;
      }
    }

    if (id.startsWith('GAS-')) {
      final req = gasRepo.getRequestById(id);
      if (req == null) return false;
      switch (req.status) {
        case GasRequestStatus.requested:
          gasRepo.updateStatus(id, GasRequestStatus.assigned);
          return true;
        case GasRequestStatus.assigned:
          gasRepo.updateStatus(id, GasRequestStatus.refilling);
          return true;
        case GasRequestStatus.refilling:
          gasRepo.updateStatus(id, GasRequestStatus.outForDelivery);
          return true;
        case GasRequestStatus.outForDelivery:
          gasRepo.updateStatus(id, GasRequestStatus.delivered);
          return true;
        case GasRequestStatus.delivered:
        case GasRequestStatus.cancelled:
          return false;
      }
    }

    if (id.startsWith('PETROL-')) {
      final req = petrolRepo.getRequestById(id);
      if (req == null) return false;
      switch (req.status) {
        case PetrolRequestStatus.requested:
          petrolRepo.updateStatus(id, PetrolRequestStatus.assigned);
          return true;
        case PetrolRequestStatus.assigned:
          petrolRepo.updateStatus(id, PetrolRequestStatus.refuelling);
          return true;
        case PetrolRequestStatus.refuelling:
          petrolRepo.updateStatus(id, PetrolRequestStatus.outForDelivery);
          return true;
        case PetrolRequestStatus.outForDelivery:
          petrolRepo.updateStatus(id, PetrolRequestStatus.delivered);
          return true;
        case PetrolRequestStatus.delivered:
        case PetrolRequestStatus.cancelled:
          return false;
      }
    }

    if (id.startsWith('GEN-')) {
      final req = generatorRepo.getRequestById(id);
      if (req == null) return false;
      switch (req.status) {
        case GeneratorRequestStatus.requested:
          generatorRepo.updateStatus(id, GeneratorRequestStatus.assigned);
          return true;
        case GeneratorRequestStatus.assigned:
          generatorRepo.updateStatus(id, GeneratorRequestStatus.inProgress);
          return true;
        case GeneratorRequestStatus.inProgress:
          generatorRepo.updateStatus(id, GeneratorRequestStatus.completed);
          return true;
        case GeneratorRequestStatus.completed:
        case GeneratorRequestStatus.cancelled:
          return false;
      }
    }

    if (id.startsWith('MAINT-')) {
      final req = maintenanceRepo.getRequestById(id);
      if (req == null) return false;
      switch (req.status) {
        case MaintenanceRequestStatus.requested:
          maintenanceRepo.updateStatus(id, MaintenanceRequestStatus.assigned);
          return true;
        case MaintenanceRequestStatus.assigned:
          maintenanceRepo.updateStatus(id, MaintenanceRequestStatus.inProgress);
          return true;
        case MaintenanceRequestStatus.inProgress:
          maintenanceRepo.updateStatus(id, MaintenanceRequestStatus.completed);
          return true;
        case MaintenanceRequestStatus.completed:
        case MaintenanceRequestStatus.cancelled:
          return false;
      }
    }

    return false;
  }
}
